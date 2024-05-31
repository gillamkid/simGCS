#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQuickControls2/QQuickStyle>
#include "TelemetrySimulator.hpp"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");
    qmlRegisterSingletonType<QFlightMode>("QFlightMode", 1, 0, "QFlightMode", q_flight_mode_singleton_provider);

    QQmlApplicationEngine engine;

    // Expose an instance of TelemetrySimulator to QML
    TelemetrySimulator telemetrySim;
    engine.rootContext()->setContextProperty("telemetrySimContextProp", &telemetrySim);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
