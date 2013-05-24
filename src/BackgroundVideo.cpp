#include "precompiled.h"

#include "BackgroundVideo.hpp"
#include "Logger.h"

namespace backgroundvideo {

using namespace bb::cascades;
using namespace bb::system;
using namespace bb::pim::message;

BackgroundVideo::BackgroundVideo(Application* app) : QObject(app)
{
	INIT_SETTING("animations", 1);
	INIT_SETTING("toastSMS", 0);
	INIT_SETTING("landscape", 1);
	INIT_SETTING("stretch", 1);
	INIT_SETTING("input", "/accounts/1000/removable/sdcard/videos");

	qmlRegisterType<bb::cascades::pickers::FilePicker>("CustomComponent", 1, 0, "FilePicker");
	qmlRegisterUncreatableType<bb::cascades::pickers::FileType>("CustomComponent", 1, 0, "FileType", "Can't instantiate");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerMode>("CustomComponent", 1, 0, "FilePickerMode", "Can't instantiate");
    qmlRegisterType<bb::device::DisplayInfo>("CustomComponent", 1, 0, "DisplayInfo");

	QmlDocument* qmlCover = QmlDocument::create("asset:///Cover.qml").parent(this);
	Control* sceneRoot = qmlCover->createRootObject<Control>();
	SceneCover* cover = SceneCover::create().content(sceneRoot);
	app->setCover(cover);

    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("app", this);
    qml->setContextProperty("persist", &m_persistance);
    qml->setContextProperty("cover", sceneRoot);

    m_root = qml->createRootObject<NavigationPane>();
    app->setScene(m_root);

	QStringList mostRecent = m_persistance.getValueFor("recent").toStringList();
	LOGGER("Most recent:" << mostRecent);

	for (int i = 0; i < mostRecent.size(); i++)
	{
    	QString uri = mostRecent[i];
    	int index = uri.lastIndexOf("/")+1;
    	LOGGER("Non empty most recent:" << uri << index);

    	QString title = uri.mid(index);
    	LOGGER("Action title:" << title);

    	AbstractActionItem* aai = ActionItem::create().title(title).image( Image("asset:///images/action_openRecent.png") );
    	aai->setProperty("uri", uri);

    	connect( aai, SIGNAL( triggered() ), this, SLOT( onMostRecentTriggered() ) );

    	m_root->top()->addAction(aai, ActionBarPlacement::InOverflow);
	}

	if ( !mostRecent.isEmpty() ) {
    	AbstractActionItem* aai = DeleteActionItem::create().title( tr("Clear") );
    	connect( aai, SIGNAL( triggered() ), this, SLOT( onClearRecentTriggered() ) );

    	m_root->top()->addAction(aai, ActionBarPlacement::InOverflow);
	}

	settingChanged("toastSMS");
	settingChanged("landscape");

    connect( &m_sms, SIGNAL( smsReceived(Message const&, QString const&) ), this, SLOT( smsReceived(Message const&, QString const&) ) );
    connect( &m_persistance, SIGNAL( settingChanged(QString const&) ), this, SLOT( settingChanged(QString const&) ) );
}


void BackgroundVideo::settingChanged(QString const& key)
{
	if (key == "toastSMS") {
		m_sms.monitorIncomingSMS( m_persistance.getValueFor("toastSMS").toInt() == 1 );
	} else if (key == "landscape") {
		OrientationSupport::instance()->setSupportedDisplayOrientation( m_persistance.getValueFor("landscape").toInt() == 1 ? SupportedDisplayOrientation::DisplayLandscape : SupportedDisplayOrientation::All);
	}
}


void BackgroundVideo::smsReceived(Message const& m, QString const& conversationKey)
{
	Q_UNUSED(conversationKey);

	setProperty( "key", m.id() );
	QString text = m.attachmentAt(0).data();
	m_persistance.showToast( tr("%1: %2").arg( m.sender().displayableName() ).arg(text), tr("OK") );
}

void BackgroundVideo::create(Application *app) {
	new BackgroundVideo(app);
}

void BackgroundVideo::onClearRecentTriggered()
{
	Page* p = m_root->top();

	for (int i = p->actionCount()-1; i >= 0; i--)
	{
		AbstractActionItem* aai = p->actionAt(i);

		if ( aai->property("uri").isValid() )
		{
			if ( p->removeAction(aai) ) {
				aai->setParent(NULL);
				delete aai;
			}
		}
	}

	m_persistance.saveValueFor( "recent", QStringList() );
}


void BackgroundVideo::onMostRecentTriggered()
{
	QString uri = sender()->property("uri").toString();
	LOGGER("onMostRecentTriggered()" << uri);

	QStringList playlist;
	playlist << uri;
	m_root->setProperty("playlist", playlist);
	QMetaObject::invokeMethod( m_root, "playFile", Q_ARG(QVariant,QVariant(uri) ) );
}


void BackgroundVideo::toastFinished(bool buttonTriggered)
{
	LOGGER("Toast finished()");

	if (buttonTriggered) {
		MessageKey mk = property("key").value<MessageKey>();
		m_sms.markRead(mk);
	}
}


void BackgroundVideo::invokeSettingsApp() {
	navigator_invoke("settings://display", NULL);
}


}
