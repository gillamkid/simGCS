#include "TelemetrySimulator.hpp"

TelemetrySimulator::TelemetrySimulator(QObject *parent) : QObject(parent) {
    m_updateTimer = new QTimer(this);
    connect(m_updateTimer, &QTimer::timeout, this, &TelemetrySimulator::update);
    m_updateTimer->start(1000 / UPDATE_FREQ_HZ);
}

void TelemetrySimulator::takeoff(){
    set_flightMode(FlightMode::TAKEOFF);
}

void TelemetrySimulator::hold(){
    set_flightMode(FlightMode::HOLD);
}

void TelemetrySimulator::land(){
    set_flightMode(FlightMode::LAND);
}

void TelemetrySimulator::goTo(QGeoCoordinate coord){
    set_goToTarget(coord);
    set_flightMode(FlightMode::GOTO);
}

void TelemetrySimulator::update(){
    // simulate battery loss
    double batteryLoss = BATTERY_DEPLETION_PERCENT_PER_SEC / UPDATE_FREQ_HZ;
    if(m_batteryPercent > batteryLoss)
        set_batteryPercent(m_batteryPercent - batteryLoss);

    // simulate flight mode behavior
    switch(m_flightMode){
        case FlightMode::GROUND:
        case FlightMode::HOLD:
            set_speed_mps(0);
            break;
        case FlightMode::TAKEOFF:
            // ascend and switch to HOLD if desired altitude reached
            set_speed_mps(10);
            set_location({m_location.latitude(), m_location.longitude(), m_location.altitude() + (m_speed_mps / UPDATE_FREQ_HZ)});
            if(m_location.altitude() >= 10)
                set_flightMode(FlightMode::HOLD);
            break;
        case FlightMode::GOTO:
            // move towards GOTO target and switch to HOLD if reached
            set_speed_mps(50);
            set_heading_deg(m_location.azimuthTo(m_goToTarget));
            set_location(m_location.atDistanceAndAzimuth(m_speed_mps / UPDATE_FREQ_HZ, m_heading_deg));
            if(m_location.distanceTo(m_goToTarget) < 5)
                set_flightMode(FlightMode::HOLD);
            break;
        case FlightMode::LAND:
            // descend and switch to GROUND once the ground is reached
            set_speed_mps(10);
            set_location({m_location.latitude(), m_location.longitude(), m_location.altitude() - (m_speed_mps / UPDATE_FREQ_HZ)});
            if(m_location.altitude() <= 0)
                set_flightMode(FlightMode::GROUND);
        break;
        default:
            exit(1); // unknown flight mode, should never happen
    }
}
