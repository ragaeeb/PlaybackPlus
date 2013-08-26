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
	m_cover.setContext("player", &m_player);

	loadRoot("main.qml");
	connect( &m_invokeManager, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
	connect( app, SIGNAL( aboutToQuit() ), this, SLOT( aboutToQuit() ) );
}



QObject* BackgroundVideo::loadRoot(QString const& qmlDoc, bool invoked)
{
	Q_UNUSED(invoked);

	qmlRegisterType<bb::cascades::pickers::FilePicker>("bb.cascades.pickers", 1, 0, "FilePicker");
	qmlRegisterUncreatableType<bb::cascades::pickers::FileType>("bb.cascades.pickers", 1, 0, "FileType", "Can't instantiate");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerMode>("bb.cascades.pickers", 1, 0, "FilePickerMode", "Can't instantiate");
    qmlRegisterType<bb::device::DisplayInfo>("bb.device", 1, 0, "DisplayInfo");
    qmlRegisterType<canadainc::TextUtils>("com.canadainc.data", 1, 0, "TextUtils");
    qmlRegisterType<QTimer>("com.canadainc.data", 1, 0, "QTimer");

    QmlDocument* qml = QmlDocument::create( QString("asset:///%1").arg(qmlDoc) ).parent(this);
    qml->setContextProperty("app", this);
    qml->setContextProperty("persist", &m_persistance);
    qml->setContextProperty("player", &m_player);
    qml->setContextProperty("sql", &m_sql);

    AbstractPane* root = qml->createRootObject<AbstractPane>();

	connect( this, SIGNAL( initialize() ), this, SLOT( init() ), Qt::QueuedConnection ); // async startup
	emit initialize();

    Application::instance()->setScene(root);

    return root;
}


void BackgroundVideo::aboutToQuit()
{
	QVariantMap map = m_player.metaData();
	QString filePath = map.value("uri").toString();

	if ( !filePath.isEmpty() )
	{
		uint position = m_player.currentPosition().toUInt();

		m_sql.setQuery( QString("INSERT OR REPLACE INTO recent (file, position) VALUES(?, %1)").arg(position) );
		QVariantList params = QVariantList() << filePath;
		m_sql.executePrepared(params, 15);
	}
}


void BackgroundVideo::hackPlayback()
{
	m_player.mediaPlayer()->setVideoOutput(VideoOutput::PrimaryDisplay);
	m_player.togglePlayback();
}


void BackgroundVideo::invoked(bb::system::InvokeRequest const& request)
{
	LOGGER("========= INVOKED WITH" << request.uri().toString() );

	m_player.play( request.uri().toString() );

	if ( request.mimeType().startsWith("video") )
	{
		QTimer::singleShot( 10, this, SLOT( hackPlayback() ) );
		m_player.toggleVideo();
	}
}


void BackgroundVideo::init()
{
	INIT_SETTING("landscape", 1);
	INIT_SETTING("stretch", 1);
	INIT_SETTING("input", "/accounts/1000/removable/sdcard/videos");

	QString database = QString("%1/database.db").arg( QDir::homePath() );
	m_sql.setSource(database);

	if ( !QFile(database).exists() ) {
		QStringList qsl;
		qsl << "CREATE TABLE recent (file TEXT PRIMARY KEY, position INTEGER DEFAULT 0, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)";
		m_sql.initSetup(qsl, 99);
	} else {
		m_sql.setQuery("SELECT count() as count from recent ORDER BY timestamp DESC LIMIT 10");
		m_sql.load(16);
	}

	InvocationUtils::validateSharedFolderAccess( tr("Warning: It seems like the app does not have access to your Shared Folder. This permission is needed for the app to access the media files so they can be played. If you leave this permission off, some features may not work properly.") );
}


void BackgroundVideo::create(Application *app) {
	new BackgroundVideo(app);
}

void BackgroundVideo::invokeSettingsApp() {
	InvocationUtils::launchSettingsApp("display");
}

}
