#include "precompiled.h"

#include "BackgroundVideo.hpp"
#include "BlueToothUtil.h"
#include "InvocationUtils.h"
#include "IOUtils.h"
#include "LazyMediaPlayer.h"
#include "Logger.h"
#include "QueryId.h"
#include "TextUtils.h"

namespace backgroundvideo {

using namespace bb::cascades;
using namespace canadainc;

BackgroundVideo::BackgroundVideo(Application* app) :
		QObject(app), m_cover("Cover.qml"), m_dirtyBookmarks(true), m_dirtyRecent(true)
{
	m_cover.setContext("player", &m_player);

	loadRoot("main.qml");
	connect( &m_invokeManager, SIGNAL( invoked(bb::system::InvokeRequest const&) ), this, SLOT( invoked(bb::system::InvokeRequest const&) ) );
	connect( app, SIGNAL( aboutToQuit() ), this, SLOT( aboutToQuit() ) );
}


QObject* BackgroundVideo::loadRoot(QString const& qmlDoc, bool invoked)
{
	Q_UNUSED(invoked);

	INIT_SETTING("tutorialCount", 0);

	qmlRegisterType<bb::cascades::pickers::FilePicker>("bb.cascades.pickers", 1, 0, "FilePicker");
	qmlRegisterUncreatableType<bb::cascades::pickers::FileType>("bb.cascades.pickers", 1, 0, "FileType", "Can't instantiate");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerMode>("bb.cascades.pickers", 1, 0, "FilePickerMode", "Can't instantiate");
	qmlRegisterType<bb::device::DisplayInfo>("bb.device", 1, 0, "DisplayInfo");
	qmlRegisterType<QTimer>("com.canadainc.data", 1, 0, "QTimer");
	qmlRegisterUncreatableType<QueryId>("com.canadainc.data", 1, 0, "QueryId", "Can't instantiate");
	qmlRegisterType<canadainc::TextUtils>("com.canadainc.data", 1, 0, "TextUtils");

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
	m_player.pause();
	QVariantMap map = m_player.metaData();
	QString filePath = map.value("uri").toString();

	if ( !filePath.isEmpty() && QFile::exists(filePath) )
	{
		uint position = m_player.currentPosition().toUInt();

		m_sql.setQuery( QString("INSERT OR REPLACE INTO recent (file, position) VALUES(?, %1)").arg(position) );
		QVariantList params = QVariantList() << filePath;
		m_sql.executePrepared(params, QueryId::SaveRecent);
	}

	if ( m_persistance.getValueFor("bluetooth") == 1 ) {
		BlueToothUtil::activate(false);
	}
}


void BackgroundVideo::addBookmark(QVariant pos, QString const& body)
{
	QVariantMap map = m_player.metaData();
	QString filePath = map.value("uri").toString();

	if ( !filePath.isEmpty() )
	{
		uint position = pos.isNull() ? m_player.currentPosition().toUInt() : pos.toUInt();

		m_sql.setQuery( QString("INSERT OR REPLACE INTO bookmarks (file, position, body) VALUES(?, %1, ?)").arg(position) );
		QVariantList params = QVariantList() << filePath << body.trimmed();
		m_sql.executePrepared(params, QueryId::SaveBookmark);

		m_dirtyBookmarks = true;
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
	INIT_SETTING("landscape", 0);
	INIT_SETTING("stretch", 1);
	INIT_SETTING("bluetooth", 0);
	INIT_SETTING("input", "/accounts/1000/removable/sdcard/videos");

	QString database = QString("%1/database.db").arg( QDir::homePath() );
	m_sql.setSource(database);

	if ( !QFile(database).exists() ) {
		IOUtils::writeFile(database);
	}

	QStringList qsl;
	qsl << "CREATE TABLE IF NOT EXISTS recent (file TEXT PRIMARY KEY, position INTEGER DEFAULT 0, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)";
	qsl << "CREATE TABLE IF NOT EXISTS bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, file TEXT, position INTEGER, body TEXT DEFAULT NULL, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)";
	qsl << "CREATE INDEX IF NOT EXISTS file_idx ON bookmarks (file)";
	m_sql.executeTransaction(qsl, QueryId::Setup);

	InvocationUtils::validateSharedFolderAccess( tr("Warning: It seems like the app does not have access to your Shared Folder. This permission is needed for the app to access the media files so they can be played. If you leave this permission off, some features may not work properly.") );

	if ( m_persistance.getValueFor("bluetooth") == 1 ) {
		BlueToothUtil::activate(true);
	}
}


void BackgroundVideo::fetchAllRecent(bool force)
{
	LOGGER("fetchAllRecent" << force);

	if (m_dirtyRecent || force)
	{
		m_sql.setQuery("SELECT * from recent ORDER BY timestamp DESC LIMIT 10");
		m_sql.load(QueryId::FetchRecent);

		m_dirtyRecent = false;
	}
}


void BackgroundVideo::fetchAllBookmarks(bool force)
{
	LOGGER("fetchAllBookmarks" << force);

	if (m_dirtyBookmarks || force)
	{
		m_sql.setQuery("SELECT * from bookmarks ORDER BY file,position");
		m_sql.load(QueryId::FetchBookmarks);

		m_dirtyBookmarks = false;
	}
}


void BackgroundVideo::deleteBookmark(int id)
{
	m_sql.setQuery( QString("DELETE FROM bookmarks WHERE id=%1").arg(id) );
	m_sql.load(QueryId::DeleteBookmark);
	m_dirtyBookmarks = true;

	fetchAllRecent();
}


void BackgroundVideo::deleteRecent(QString const& file)
{
	m_sql.setQuery( QString("DELETE FROM recent WHERE file=?").arg(file) );
	QVariantList params = QVariantList() << file;
	m_sql.executePrepared(params, QueryId::DeleteRecent);
	m_dirtyRecent = true;

	fetchAllRecent();
}


void BackgroundVideo::create(Application *app) {
	new BackgroundVideo(app);
}

void BackgroundVideo::invokeSettingsApp() {
	InvocationUtils::launchSettingsApp("display");
}

bool BackgroundVideo::deleteFile(QString const& file, bool removeBookmarks)
{
	bool result = QFile::remove(file);

	deleteRecent(file);

	if (removeBookmarks) {
		m_sql.setQuery("DELETE FROM bookmarks WHERE file=?");
		QVariantList params = QVariantList() << file;
		m_sql.executePrepared(params, QueryId::DeleteFile);
	}

	return result;
}


QString BackgroundVideo::exportAllBookmarks(QObject* q)
{
	GroupDataModel* gdm = static_cast<GroupDataModel*>(q);
	QList<QVariantMap> list = gdm->toListOfMaps();
	QString result;

	if ( !list.isEmpty() )
	{
		QString last = list.first().value("file").toString();
		result = last.mid( last.lastIndexOf("/")+1 )+"\n";

		for (int i = 0; i < list.size(); i++)
		{
			QVariantMap current = list[i];
			QString file = current.value("file").toString();

			if (last != file) {
				last = file;
				result += "================================\n\n";
				result += last.mid( last.lastIndexOf("/")+1 )+"\n";
			}

			QString t = formatTime( current.value("position").toInt() );
			result += QString("%1: %2").arg(t).arg( current.value("body").toString() )+"\n";
		}
	}

	return result;
}

void BackgroundVideo::clearAllRecent()
{
    m_sql.setQuery("DELETE from recent");
    m_sql.load(QueryId::ClearAllRecent);
    m_dirtyRecent = true;

    fetchAllRecent();
}

void BackgroundVideo::clearAllBookmarks()
{
    m_sql.setQuery("DELETE from bookmarks");
    m_sql.load(QueryId::ClearAllBookmarks);
	m_dirtyBookmarks = true;

    fetchAllBookmarks();
}


QString BackgroundVideo::formatTime(unsigned int duration)
{
    unsigned int secs = floor(duration / 1000);
    secs %= 60;
    unsigned int mins = floor( (duration / (1000 * 60) ) % 60);
    unsigned int hrs = floor( (duration / (1000 * 60 * 60) ) % 24);

    QString seconds = QString::number(secs).rightJustified(2,'0');
    QString minutes = QString::number(mins).rightJustified(2,'0');
    QString hours = hrs > 0 ? QString("%1:").arg(hrs) : "";

    return QString("%1%2:%3").arg(hours).arg(minutes).arg(seconds);
}


}
