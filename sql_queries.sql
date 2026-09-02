DROP TABLE IF EXISTS hotel_bookings;

CREATE TABLE hotel_bookings (
    hotel VARCHAR(50),
    is_canceled INTEGER,
    lead_time INTEGER,
    arrival_date_year INTEGER,
    arrival_date_month VARCHAR(20),
    arrival_date_week_number INTEGER,
    arrival_date_day_of_month INTEGER,
    stays_in_weekend_nights INTEGER,
    stays_in_week_nights INTEGER,
    adults INTEGER,
    children INTEGER,
    babies INTEGER,
    meal VARCHAR(50),
    country VARCHAR(10),
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(50),
    is_repeated_guest INTEGER,
    previous_cancellations INTEGER,
    previous_bookings_not_canceled INTEGER,
    reserved_room_type VARCHAR(10),
    assigned_room_type VARCHAR(10),
    booking_changes INTEGER,
    deposit_type VARCHAR(50),
    agent DOUBLE PRECISION,
    days_in_waiting_list INTEGER,
    customer_type VARCHAR(50),
    adr DOUBLE PRECISION,
    required_car_parking_spaces INTEGER,
    total_of_special_requests INTEGER,
    reservation_status VARCHAR(50),
    reservation_status_date DATE,
    arrival_date DATE,
    total_guests INTEGER,
    stay_nights INTEGER,
    booking_status VARCHAR(20)
);

INSERT INTO hotel_bookings
SELECT
    hotel,
    NULLIF(is_canceled, '')::INTEGER,
    NULLIF(lead_time, '')::INTEGER,
    NULLIF(arrival_date_year, '')::INTEGER,
    arrival_date_month,
    NULLIF(arrival_date_week_number, '')::INTEGER,
    NULLIF(arrival_date_day_of_month, '')::INTEGER,
    NULLIF(stays_in_weekend_nights, '')::INTEGER,
    NULLIF(stays_in_week_nights, '')::INTEGER,
    NULLIF(adults, '')::INTEGER,
    NULLIF(children, '')::INTEGER,
    NULLIF(babies, '')::INTEGER,
    meal,
    country,
    market_segment,
    distribution_channel,
    NULLIF(is_repeated_guest, '')::INTEGER,
    NULLIF(previous_cancellations, '')::INTEGER,
    NULLIF(previous_bookings_not_canceled, '')::INTEGER,
    reserved_room_type,
    assigned_room_type,
    NULLIF(booking_changes, '')::INTEGER,
    deposit_type,
    NULLIF(agent, '')::DOUBLE PRECISION,
    NULLIF(days_in_waiting_list, '')::INTEGER,
    customer_type,
    NULLIF(adr, '')::DOUBLE PRECISION,
    NULLIF(required_car_parking_spaces, '')::INTEGER,
    NULLIF(total_of_special_requests, '')::INTEGER,
    reservation_status,
    NULLIF(reservation_status_date, '')::DATE,
    NULLIF(arrival_date, '')::DATE,
    NULLIF(total_guests, '')::INTEGER,
    NULLIF(stay_nights, '')::INTEGER,
    booking_status
FROM hotel_bookings_raw;

SELECT COUNT(*) AS total_records
FROM hotel_bookings;

SELECT *
FROM hotel_bookings
LIMIT 10;

SELECT
    booking_status,
    COUNT(*) AS bookings
FROM hotel_bookings
GROUP BY booking_status;

--Q1 — Highest cancellation percentage by hotel
SELECT
    hotel,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancelled_bookings,
    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_percentage
FROM hotel_bookings
GROUP BY hotel
ORDER BY cancellation_percentage DESC;

--Q2 — Months with highest bookings
SELECT
    arrival_date_month,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY arrival_date_month
ORDER BY total_bookings DESC;

--Q3 — Customer types with highest average ADR
SELECT
    customer_type,
    COUNT(*) AS total_bookings,
    ROUND(AVG(adr)::numeric, 2) AS average_adr
FROM hotel_bookings
GROUP BY customer_type
ORDER BY average_adr DESC;

--Q4 — Lead time vs cancellation
SELECT
    CASE
        WHEN lead_time BETWEEN 0 AND 30 THEN '0-30 days'
        WHEN lead_time BETWEEN 31 AND 90 THEN '31-90 days'
        WHEN lead_time BETWEEN 91 AND 180 THEN '91-180 days'
        WHEN lead_time > 180 THEN '>180 days'
    END AS lead_time_group,

    COUNT(*) AS total_bookings,

    SUM(is_canceled) AS cancelled_bookings,

    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_percentage

FROM hotel_bookings

GROUP BY
    CASE
        WHEN lead_time BETWEEN 0 AND 30 THEN '0-30 days'
        WHEN lead_time BETWEEN 31 AND 90 THEN '31-90 days'
        WHEN lead_time BETWEEN 91 AND 180 THEN '91-180 days'
        WHEN lead_time > 180 THEN '>180 days'
    END

ORDER BY cancellation_percentage DESC;

--Q5 — Top 5 countries with completed bookings
SELECT
    country,
    COUNT(*) AS completed_bookings
FROM hotel_bookings
WHERE booking_status = 'Completed'
GROUP BY country
ORDER BY completed_bookings DESC
LIMIT 5;

--Overall KPI Query
-- STEP 6: Overall KPI Summary

SELECT
    COUNT(*) AS total_bookings,

    SUM(
        CASE
            WHEN booking_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS successful_bookings,

    SUM(
        CASE
            WHEN booking_status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_bookings,

    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate,

    ROUND(
        AVG(adr)::numeric,
        2
    ) AS average_adr,

    ROUND(
        AVG(stay_nights),
        2
    ) AS average_stay_duration

FROM hotel_bookings;