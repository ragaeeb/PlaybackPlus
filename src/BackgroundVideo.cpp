#include "precompiled.h"

#include "BackgroundVideo.hpp"
#include "InvocationUtils.h"
#include "LazyMediaPlayer.h"
#include "Logger.h"
#include "TextUtils.h"

namespace backgroundvideo {

using namespace bb::cascades;
using namespace canadainc;

BackgroundVideo::BackgroundVideo(Application* app) : QObject(app), m_cover("Cover.qml")
{
	qmlRegisterType<bb::cascades::pickers::FilePicker>("bb.cascades.pickers", 1, 0, "FilePicker");
	qmlRegisterUncreatableType<bb::cascades::pickers::FileType>("bb.cascades.pickers", 1, 0, "FileType", "Can't instantiate");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerMode>("bb.cascades.pickers", 1, 0, "FilePickerMode", "Can't instantiate");
    qmlRegisterType<bb::device::DisplayInfo>("bb.device", 1, 0, "DisplayInfo");
    qmlRegisterType<canadainc::TextUtils>("com.canadainc.data", 1, 0, "TextUtils");
    qmlRegisterType<QTimer>("com.canadainc.data", 1, 0, "QTimer");

    QmlDocument* qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("app", this);
    qml->setContextProperty("persist", &m_persistance);
    qml->setContextProperty("player", &m_player);

    m_root = qml->createRootObject<NavigationPane>();
    app->setScene(m_root);

	connect( this, SIGNAL( initialize() ), this, SLOT( init() ), Qt::QueuedConnection ); // async startup

	emit initialize();
}


void BackgroundVideo::init()
{
	INIT_SETTING("landscape", 1);
	INIT_SETTING("stretch", 1);
	INIT_SETTING("input", "/accounts/1000/removable/sdcard/videos");

    connect( &m_persistance, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ) );

	settingChanged("landscape");

	InvocationUtils::validateSharedFolderAccess( tr("Warning: It seems like the app does not have access to your Shared Folder. This permission is needed for the app to access the media files so they can be played. If you leave this permission off, some features may not work properly.") );
}


void BackgroundVideo::settingChanged(QString const& key)
{
	if (key == "landscape") {
		OrientationSupport::instance()->setSupportedDisplayOrientation( m_persistance.getValueFor("landscape").toInt() == 1 ? SupportedDisplayOrientation::DisplayLandscape : SupportedDisplayOrientation::All);
	}
}


void BackgroundVideo::create(Application *app) {
	new BackgroundVideo(app);
}

void BackgroundVideo::invokeSettingsApp() {
	InvocationUtils::launchSettingsApp("display");
}

}
