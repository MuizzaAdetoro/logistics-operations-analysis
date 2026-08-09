-- ============================================================
CREATE DATABASE Logistics;

-- ============================================================
-- TABLES 
-- ============================================================

CREATE TABLE drivers (
    driver_id           VARCHAR(10) PRIMARY KEY,
    first_name          VARCHAR(50),
    last_name           VARCHAR(50),
    hire_date           DATE,
    termination_date    DATE,          -- NULL = still active
    license_number      VARCHAR(20),
    license_state       CHAR(2),
    date_of_birth       DATE,
    home_terminal       VARCHAR(50),
    employment_status   VARCHAR(20),
    cdl_class           CHAR(1),
    years_experience    INTEGER
);

CREATE TABLE trucks (
    truck_id                VARCHAR(10) PRIMARY KEY,
    unit_number             INTEGER,
    make                    VARCHAR(30),
    model_year              INTEGER,
    vin                     VARCHAR(20),
    acquisition_date        DATE,
    acquisition_mileage     INTEGER,
    fuel_type               VARCHAR(20),
    tank_capacity_gallons   INTEGER,
    status                  VARCHAR(20),
    home_terminal           VARCHAR(50)
);

CREATE TABLE trailers (
    trailer_id          VARCHAR(10) PRIMARY KEY,
    trailer_number      INTEGER,
    trailer_type        VARCHAR(30),
    length_feet         INTEGER,
    model_year          INTEGER,
    vin                 VARCHAR(20),
    acquisition_date    DATE,
    status              VARCHAR(20),
    current_location    VARCHAR(50)
);

CREATE TABLE customers (
    customer_id                 VARCHAR(10) PRIMARY KEY,
    customer_name               VARCHAR(100),
    customer_type               VARCHAR(30),
    credit_terms_days           INTEGER,
    primary_freight_type        VARCHAR(30),
    account_status              VARCHAR(20),
    contract_start_date         DATE,
    annual_revenue_potential    INTEGER
);

CREATE TABLE facilities (
    facility_id     VARCHAR(10) PRIMARY KEY,
    facility_name   VARCHAR(100),
    facility_type   VARCHAR(30),
    city            VARCHAR(50),
    state           CHAR(2),
    latitude        NUMERIC(9,4),
    longitude       NUMERIC(9,4),
    dock_doors      INTEGER,
    operating_hours VARCHAR(20)
);

CREATE TABLE routes (
    route_id                VARCHAR(10) PRIMARY KEY,
    origin_city             VARCHAR(50),
    origin_state            CHAR(2),
    destination_city        VARCHAR(50),
    destination_state       CHAR(2),
    typical_distance_miles  INTEGER,
    base_rate_per_mile      NUMERIC(5,2),
    fuel_surcharge_rate     NUMERIC(5,2),
    typical_transit_days    INTEGER
);

-- ============================================================
-- TRANSACTION TABLES
-- ============================================================

CREATE TABLE loads (
    load_id                 VARCHAR(15) PRIMARY KEY,
    customer_id             VARCHAR(10) REFERENCES customers(customer_id),
    route_id                VARCHAR(10) REFERENCES routes(route_id),
    load_date               DATE,
    load_type               VARCHAR(30),
    weight_lbs              INTEGER,
    pieces                  INTEGER,
    revenue                 NUMERIC(10,2),
    fuel_surcharge          NUMERIC(10,2),
    accessorial_charges     NUMERIC(10,2),
    load_status             VARCHAR(20),
    booking_type            VARCHAR(20)
);

CREATE TABLE trips (
    trip_id                 VARCHAR(15) PRIMARY KEY,
    load_id                 VARCHAR(15) REFERENCES loads(load_id),
    driver_id               VARCHAR(10) REFERENCES drivers(driver_id),
    truck_id                VARCHAR(10) REFERENCES trucks(truck_id),
    trailer_id              VARCHAR(10) REFERENCES trailers(trailer_id),
    dispatch_date           DATE,
    actual_distance_miles   INTEGER,
    actual_duration_hours   NUMERIC(8,2),
    fuel_gallons_used       NUMERIC(8,2),
    average_mpg             NUMERIC(5,2),
    idle_time_hours         NUMERIC(8,2),
    trip_status             VARCHAR(20)
);

CREATE TABLE fuel_purchases (
    fuel_purchase_id    VARCHAR(15) PRIMARY KEY,
    trip_id             VARCHAR(15) REFERENCES trips(trip_id),
    truck_id            VARCHAR(10) REFERENCES trucks(truck_id),
    driver_id           VARCHAR(10) REFERENCES drivers(driver_id),
    purchase_date       TIMESTAMP,
    location_city       VARCHAR(50),
    location_state      CHAR(2),
    gallons             NUMERIC(8,2),
    price_per_gallon    NUMERIC(6,3),
    total_cost          NUMERIC(10,2),
    fuel_card_number    VARCHAR(20)
);

CREATE TABLE maintenance_records (
    maintenance_id      VARCHAR(15) PRIMARY KEY,
    truck_id            VARCHAR(10) REFERENCES trucks(truck_id),
    maintenance_date    DATE,
    maintenance_type    VARCHAR(30),
    odometer_reading    INTEGER,
    labor_hours         NUMERIC(6,2),
    labor_cost          NUMERIC(10,2),
    parts_cost          NUMERIC(10,2),
    total_cost          NUMERIC(10,2),
    facility_location   VARCHAR(50),
    downtime_hours      NUMERIC(8,2),
    service_description VARCHAR(200)
);

CREATE TABLE delivery_events (
    event_id            VARCHAR(15) PRIMARY KEY,
    load_id             VARCHAR(15) REFERENCES loads(load_id),
    trip_id             VARCHAR(15) REFERENCES trips(trip_id),
    event_type          VARCHAR(20),
    facility_id         VARCHAR(10) REFERENCES facilities(facility_id),
    scheduled_datetime  TIMESTAMP,
    actual_datetime     TIMESTAMP,
    detention_minutes   INTEGER,
    on_time_flag        BOOLEAN,
    location_city       VARCHAR(50),
    location_state      CHAR(2)
);

CREATE TABLE safety_incidents (
    incident_id             VARCHAR(15) PRIMARY KEY,
    trip_id                 VARCHAR(15) REFERENCES trips(trip_id),
    truck_id                VARCHAR(10) REFERENCES trucks(truck_id),
    driver_id               VARCHAR(10) REFERENCES drivers(driver_id),
    incident_date           TIMESTAMP,
    incident_type           VARCHAR(50),
    location_city           VARCHAR(50),
    location_state          CHAR(2),
    at_fault_flag           BOOLEAN,
    injury_flag             BOOLEAN,
    vehicle_damage_cost     NUMERIC(10,2),
    cargo_damage_cost       NUMERIC(10,2),
    claim_amount            NUMERIC(10,2),
    preventable_flag        BOOLEAN,
    description             TEXT
);

-- ============================================================
-- AGGREGATED METRIC TABLES
-- ============================================================

CREATE TABLE driver_monthly_metrics (
    driver_id               VARCHAR(10) REFERENCES drivers(driver_id),
    month                   DATE,
    trips_completed         INTEGER,
    total_miles             INTEGER,
    total_revenue           NUMERIC(12,2),
    average_mpg             NUMERIC(5,2),
    total_fuel_gallons      NUMERIC(10,2),
    on_time_delivery_rate   NUMERIC(5,3),
    average_idle_hours      NUMERIC(6,2),
    PRIMARY KEY (driver_id, month)
);

CREATE TABLE truck_utilization_metrics (
    truck_id            VARCHAR(10) REFERENCES trucks(truck_id),
    month               DATE,
    trips_completed     INTEGER,
    total_miles         INTEGER,
    total_revenue       NUMERIC(12,2),
    average_mpg         NUMERIC(5,2),
    maintenance_events  INTEGER,
    maintenance_cost    NUMERIC(10,2),
    downtime_hours      NUMERIC(8,2),
    utilization_rate    NUMERIC(5,2),
    PRIMARY KEY (truck_id, month)
);

-- ============================================================
-- VERIFY LOAD COUNTS
-- ============================================================

SELECT 'drivers' AS table_name, COUNT(*) AS row_count FROM drivers
UNION ALL SELECT 'trucks', COUNT(*) FROM trucks
UNION ALL SELECT 'trailers', COUNT(*) FROM trailers
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'facilities', COUNT(*) FROM facilities
UNION ALL SELECT 'routes', COUNT(*) FROM routes
UNION ALL SELECT 'loads', COUNT(*) FROM loads
UNION ALL SELECT 'trips', COUNT(*) FROM trips
UNION ALL SELECT 'fuel_purchases', COUNT(*) FROM fuel_purchases
UNION ALL SELECT 'maintenance_records', COUNT(*) FROM maintenance_records
UNION ALL SELECT 'delivery_events', COUNT(*) FROM delivery_events
UNION ALL SELECT 'safety_incidents', COUNT(*) FROM safety_incidents
UNION ALL SELECT 'driver_monthly_metrics', COUNT(*) FROM driver_monthly_metrics
UNION ALL SELECT 'truck_utilization_metrics', COUNT(*) FROM truck_utilization_metrics
ORDER BY table_name;

-- ============================================================
-- CUSTOMER PERFORMANCE ANALYSIS
/*Purpose: Identify our top 20 customers by revenue. join the customers table to the loads table to connect
each customer to their shipments, then summarize total loads,total revenue, average revenue per load, 
fuel surcharges and accessorial charges per customer.Result is ordered by highest revenue first.*/
SELECT c.customer_id, c.customer_name, c.customer_type,c.account_status,
    COUNT(l.load_id) AS total_loads,
    ROUND(SUM(l.revenue)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(l.revenue)::NUMERIC, 2) AS avg_revenue_per_load,
    ROUND(SUM(l.fuel_surcharge)::NUMERIC, 2) AS total_fuel_surcharge,
    ROUND(SUM(l.accessorial_charges)::NUMERIC, 2) AS total_accessorial
FROM customers c
JOIN loads l ON c.customer_id = l.customer_id
GROUP BY c.customer_id
ORDER BY total_revenue DESC
LIMIT 20;

-- ============================================================
-- CUSTOMER OPERATIONAL COST ANALYSIS
/*Purpose: Add delivery performance and detention data to customer analysis. join loads to delivery_events to 
calculate average on-time rate and total detention minutes per customer.
High detention = customer is wasting driver time = hidden cost.*/
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
ORDER BY total_revenue DESC
LIMIT 20;

-- ============================================================
-- ROUTE PROFITABILITY ANALYSIS
/*Purpose: Determine which routes generate the most profit after fuel costs. join loads and trips to routes to 
calculate revenue per mile and fuel cost per mile. The difference shows true route profitability.*/
SELECT r.route_id, r.origin_city || ', ' || r.destination_city AS route,
    r.typical_distance_miles, COUNT(l.load_id) AS total_loads,
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
ORDER BY revenue_per_mile DESC
LIMIT 20;

-- ============================================================
-- MAINTENANCE COST AND DOWNTIME ANALYSIS
/*Purpose: Identify which trucks are consuming the most maintenance budget and sitting out of service 
the longest. High maintenance cost + high downtime = truck is hurting profitability because it costs 
money to fix and earns nothing while being repaired. join maintenance_records to trucks to get truck details.*/
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
GROUP BY t.truck_id, t.make, t.model_year, t.status, t.home_terminal
ORDER BY total_maintenance_cost DESC
LIMIT 20;

-- ============================================================
-- FLEET MAINTENANCE COST BY TYPE
/*Purpose: Identify which maintenance categories are consuming the most budget across the entire fleet.
This shows whether the fleet has a systemic mechanical problem such as recurring engine failures or 
brake issues that need a fleet-wide intervention rather than truck-by-truck fixes.*/
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
-- SAFETY INCIDENT ANALYSIS
/*Purpose: Identify where safety incidents are concentrated by driver, incident type, fault and financial 
impact. Safety incidents create insurance claims, raise fleet-wide premiums and damage the company's reputation.
We join safety_incidents to drivers and trips to get full context on each incident.*/
SELECT d.driver_id, d.first_name || ' ' || d.last_name AS driver_name, d.employment_status,
    d.years_experience, COUNT(si.incident_id) AS total_incidents,
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
-- YEARLY AND MONTHLY REVENUE TREND ANALYSIS
/*Purpose: Track how revenue, load volume and operational costs are changing over time across 2022 to 2024.
This shows whether the business is growing or declining, which months are peak periods and which are slow 
seasons. Understanding seasonality helps the business plan driver availability, truck maintenance scheduling 
and customer contracts.*/
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

