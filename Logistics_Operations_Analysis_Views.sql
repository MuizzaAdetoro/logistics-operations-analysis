-- ============================================================
-- LOGISTICS CAPSTONE - Create Analysis Views
-- These views save your 6 analysis queries as reusable tables
-- that Power BI will connect to directly

-- ============================================================
-- VIEW 1: CUSTOMER REVENUE RANKING
-- ============================================================
/*Purpose: Identify top customers by revenue.We join customers to loads to connect each customer
to their shipments and summarize total loads, revenue,fuel surcharges and accessorial charges per customer.
Result is ordered by highest revenue first.*/
CREATE OR REPLACE VIEW vw_customer_revenue AS
SELECT c.customer_id, c.customer_name, c.customer_type, c.account_status,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(l.revenue)::NUMERIC, 2) AS avg_revenue_per_load,
    ROUND(SUM(l.fuel_surcharge)::NUMERIC, 2) AS total_fuel_surcharge,
    ROUND(SUM(l.accessorial_charges)::NUMERIC, 2) AS total_accessorial
FROM customers c
JOIN loads l ON c.customer_id = l.customer_id
GROUP BY c.customer_id
ORDER BY total_revenue DESC;

-- ============================================================
-- VIEW 2: CUSTOMER OPERATIONAL COST ANALYSIS
-- ============================================================
/*Purpose: Add delivery performance and detention data to customer analysis. join loads to delivery_events to 
calculate average on-time rate and total detention minutes per customer.
High detention = customer is wasting driver time = hidden cost.*/
CREATE OR REPLACE VIEW vw_customer_operations AS
SELECT c.customer_name, c.customer_type, c.account_status,
    COUNT(DISTINCT l.load_id) AS total_loads,
    ROUND(SUM(l.revenue)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(de.detention_minutes)::NUMERIC, 2) AS avg_detention_minutes,
    SUM(de.detention_minutes) AS total_detention_minutes,
    COUNT(CASE WHEN de.on_time_flag = TRUE THEN 1 END) AS on_time_deliveries,
    COUNT(CASE WHEN de.on_time_flag = FALSE THEN 1 END) AS late_deliveries
FROM customers c
JOIN loads l ON c.customer_id = l.customer_id
JOIN delivery_events de ON l.load_id = de.load_id
GROUP BY c.customer_id
ORDER BY total_revenue DESC;

-- ============================================================
-- VIEW 3: ROUTE PROFITABILITY ANALYSIS
-- ============================================================
/*Purpose: Determine which routes generate the most profit after fuel costs. join loads and trips to routes to 
calculate revenue per mile and fuel cost per mile. The difference shows true route profitability.*/
CREATE OR REPLACE VIEW vw_route_profitability AS
SELECT r.route_id, r.origin_city || ' , ' || r.destination_city AS route, r.typical_distance_miles,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue)::NUMERIC, 2) AS total_revenue,
    ROUND(SUM(t.fuel_gallons_used)::NUMERIC, 2) AS total_fuel_gallons,
    ROUND(AVG(l.revenue / NULLIF(t.actual_distance_miles, 0))::NUMERIC, 2) AS revenue_per_mile,
    ROUND(AVG(t.average_mpg)::NUMERIC, 2) AS avg_mpg,
    ROUND(AVG(t.idle_time_hours)::NUMERIC, 2) AS avg_idle_hours
FROM routes r
JOIN loads l ON r.route_id = l.route_id
JOIN trips t ON l.load_id = t.load_id
WHERE t.driver_id IS NOT NULL
GROUP BY r.route_id 
ORDER BY revenue_per_mile DESC;

-- ============================================================
-- VIEW 4: TRUCK MAINTENANCE COST AND DOWNTIME
-- ============================================================
/*Purpose: Identify which trucks are consuming the most maintenance budget and sitting out of service 
the longest. High maintenance cost + high downtime = truck is hurting profitability because it costs 
money to fix and earns nothing while being repaired. join maintenance_records to trucks to get truck details.*/
CREATE OR REPLACE VIEW vw_truck_maintenance AS
SELECT t.truck_id, t.make, t.model_year, t.status, t.home_terminal,
    COUNT(m.maintenance_id) AS total_maintenance_events,
    ROUND(SUM(m.total_cost)::NUMERIC, 2) AS total_maintenance_cost,
    ROUND(AVG(m.total_cost)::NUMERIC, 2) AS avg_cost_per_event,
    ROUND(SUM(m.downtime_hours)::NUMERIC, 2) AS total_downtime_hours,
    ROUND(AVG(m.downtime_hours)::NUMERIC, 2) AS avg_downtime_per_event,
    ROUND(SUM(m.labor_cost)::NUMERIC, 2) AS total_labor_cost,
    ROUND(SUM(m.parts_cost)::NUMERIC, 2) AS total_parts_cost,
    MODE() WITHIN GROUP (ORDER BY m.maintenance_type) AS most_common_maintenance
FROM trucks t
JOIN maintenance_records m ON t.truck_id = m.truck_id
GROUP BY t.truck_id
ORDER BY total_maintenance_cost DESC;

-- ============================================================
-- VIEW 5: FLEET MAINTENANCE COST BY TYPE
-- ============================================================
/*Purpose: Identify which maintenance categories are consuming the most budget across the entire fleet.
This shows whether the fleet has a systemic mechanical problem such as recurring engine failures or 
brake issues that need a fleet-wide intervention rather than truck-by-truck fixes.*/
CREATE OR REPLACE VIEW vw_fleet_maintenance_by_type AS
SELECT m.maintenance_type,
    COUNT(m.maintenance_id) AS total_event,
    ROUND(SUM(m.total_cost)::NUMERIC, 2) AS total_cost,
    ROUND(AVG(m.total_cost)::NUMERIC, 2) AS avg_cost_per_event,
    ROUND(SUM(m.downtime_hours)::NUMERIC, 2) AS total_downtime_hours,
    ROUND(AVG(m.downtime_hours)::NUMERIC, 2) AS avg_downtime_per_event,
    ROUND(SUM(m.labor_cost)::NUMERIC, 2) AS total_labor_cost,
    ROUND(SUM(m.parts_cost)::NUMERIC, 2) AS total_parts_cost
FROM maintenance_records m
GROUP BY m.maintenance_type
ORDER BY total_cost DESC;

-- ============================================================
-- VIEW 6: DRIVER SAFETY INCIDENT ANALYSIS
-- ============================================================
/*Purpose: Identify where safety incidents are concentrated by driver, incident type, fault and financial 
impact. Safety incidents create insurance claims, raise fleet-wide premiums and damage the company's reputation.
We join safety_incidents to drivers and trips to get full context on each incident.*/
CREATE OR REPLACE VIEW vw_driver_safety AS
SELECT d.driver_id, d.first_name || ' ' || d.last_name AS driver_name, d.employment_status, d.years_experience,
    COUNT(si.incident_id) AS total_incidents,
    COUNT(CASE WHEN si.at_fault_flag = TRUE THEN 1 END) AS at_fault_incidents,
    COUNT(CASE WHEN si.preventable_flag = TRUE THEN 1 END) AS preventable_incidents,
    COUNT(CASE WHEN si.injury_flag = TRUE THEN 1 END) AS incidents_with_injury,
    ROUND(SUM(si.claim_amount)::NUMERIC, 2) AS total_claim_amount,
    ROUND(AVG(si.claim_amount)::NUMERIC, 2) AS avg_claim_per_incident,
    MODE() WITHIN GROUP (ORDER BY si.incident_type) AS most_common_incident_type
FROM drivers d
JOIN safety_incidents si ON d.driver_id = si.driver_id
GROUP BY d.driver_id
ORDER BY total_incidents DESC, total_claim_amount DESC;

-- ============================================================
-- VIEW 7: MONTHLY REVENUE TREND ANALYSIS
-- ============================================================
/*Purpose: Track how revenue, load volume and operational costs are changing over time across 2022 to 2024.
This shows whether the business is growing or declining, which months are peak periods and which are slow 
seasons. Understanding seasonality helps the business plan driver availability, truck maintenance scheduling 
and customer contracts.*/
CREATE OR REPLACE VIEW vw_monthly_revenue_trend AS
SELECT EXTRACT(YEAR FROM l.load_date) AS year,
    EXTRACT(MONTH FROM l.load_date) AS month_number,
    TO_CHAR(l.load_date, 'Month') AS month_name,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(l.revenue)::NUMERIC, 2) AS avg_revenue_per_load,
    ROUND(SUM(l.fuel_surcharge)::NUMERIC, 2) AS total_fuel_surcharge,
    ROUND(SUM(l.accessorial_charges)::NUMERIC, 2) AS total_accessorial_charges,
    COUNT(CASE WHEN l.load_type = 'Dry Van' THEN 1 END) AS dry_van_loads,
    COUNT(CASE WHEN l.load_type = 'Refrigerated' THEN 1 END) AS refrigerated_loads
FROM loads l
GROUP BY EXTRACT(YEAR FROM l.load_date),EXTRACT(MONTH FROM l.load_date),
TO_CHAR(l.load_date, 'Month')
ORDER BY year, month_number;


-- ============================================================
-- VERIFY ALL VIEWS WERE CREATED SUCCESSFULLY
-- ============================================================
SELECT table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

