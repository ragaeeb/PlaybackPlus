#include "BackgroundVideo.hpp"
#include "Logger.h"

#include <bb/system/InvokeManager>
#include <bb/system/SystemToast>

#include <bb/cascades/ActionItem>
#include <bb/cascades/Application>
#include <bb/cascades/Control>
#include <bb/cascades/DeleteActionItem>
#include <bb/cascades/NavigationPane>
#include <bb/cascades/OrientationSupport>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/SceneCover>

#include <bb/pim/account/AccountService>
#include <bb/pim/message/MessageService>

namespace backgroundvideo {

using namespace bb::cascades;
using namespace bb::system;
using namespace bb::pim::account;
using namespace bb::pim::message;

BackgroundVideo::BackgroundVideo(Application* app) : QObject(app), m_accountKey(0), m_ms(NULL), m_connected(false)
{
	if ( getValueFor("stretch").isNull() ) { // first run
		LOGGER("BackgroundVideo()::First run!");
		saveValueFor("animations", 1);
		saveValueFor("toastSMS", 1);
		saveValueFor("landscape", 1);
		saveValueFor("stretch", 1);
		saveValueFor("input", "/accounts/1000/removable/sdcard/videos");
	}

	OrientationSupport::instance()->setSupportedDisplayOrientation( getValueFor("landscape").toInt() == 1 ? SupportedDisplayOrientation::DisplayLandscape : SupportedDisplayOrientation::All);

	QmlDocument* qmlCover = QmlDocument::create("asset:///Cover.qml").parent(this);
	Control* sceneRoot = qmlCover->createRootObject<Control>();
	SceneCover* cover = SceneCover::create().content(sceneRoot);
	app->setCover(cover);

    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("app", this);
    qml->setContextProperty("cover", sceneRoot);

    m_root = qml->createRootObject<NavigationPane>();
    app->setScene(m_root);

	QStringList mostRecent = getValueFor("recent").toStringList();
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

	if ( getValueFor("toastSMS").toInt() == 1 ) {
		monitorSMS(true);
	}
}


void BackgroundVideo::create(Application *app) {
	new BackgroundVideo(app);
}

void BackgroundVideo::onClearRecentTriggered()
{
	m_root->top()->removeAllActions();
	saveValueFor( "recent", QStringList() );
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


void BackgroundVideo::monitorSMS(bool const& value)
{
	LOGGER("monitorSMS" << value);

	if (value)
	{
		if (!m_accountKey) {
			LOGGER("no account key");
		    AccountService as;

		    QList<Account> accounts = as.accounts(Service::Messages, "sms-mms");

		    if ( !accounts.isEmpty() ) {
		    	m_accountKey = accounts[0].id();
		    	LOGGER("found account key" << m_accountKey);
			    m_ms = new MessageService(this);
			    LOGGER("monitorSMS::created message service");
		    }
		}

	    if (m_accountKey && !m_connected) {
	    	LOGGER("connecting for callback");
	    	m_connected = connect( m_ms, SIGNAL( messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey) ), this, SLOT( messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey) ) );
	    }
	} else if (m_ms) {
		LOGGER("disconnecting from monitorSMS()");
		disconnect( m_ms, SIGNAL( messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey) ), this, SLOT( messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey) ) );
		m_connected = false;
	}
}


void BackgroundVideo::messageAdded(bb::pim::account::AccountKey ak, bb::pim::message::ConversationKey ck, bb::pim::message::MessageKey mk)
{
	Q_UNUSED(ck);

	LOGGER("messageAdded()" << ak << mk);

	if (ak == m_accountKey)
	{
		Message m = m_ms->message(ak, mk);

		if ( m.isInbound() && m.attachmentCount() > 0 && ( m.attachmentAt(0).mimeType() == "text/plain" ) )
		{
			SystemToast* toast = new SystemToast(this);
			toast->setProperty("key", mk);
			toast->button()->setLabel( tr("OK") );
			connect( toast, SIGNAL( finished(bb::system::SystemUiResult::Type) ), this, SLOT( finished(bb::system::SystemUiResult::Type) ) );

			QString text = m.attachmentAt(0).data();
			toast->setBody( tr("%1: %2").arg( m.sender().displayableName() ).arg(text) );
			LOGGER("Show toast: " << text);
			toast->show();
		}
	}
}


void BackgroundVideo::finished(bb::system::SystemUiResult::Type value)
{
	LOGGER("Toast finished()");

	if (value == SystemUiResult::ButtonSelection) {
		MessageKey mk = sender()->property("key").value<MessageKey>();
		LOGGER("Button selection, marking as read" << m_accountKey << mk);
		m_ms->markRead(m_accountKey, mk);
	}

	LOGGER("Delete toast");
	sender()->deleteLater();
}


void BackgroundVideo::invokeSettingsApp()
{
	InvokeManager invokeManager;

	InvokeRequest request;
	request.setTarget("sys.settings.target");
	request.setAction("bb.action.OPEN");
	request.setMimeType("settings/view");
	request.setUri( QUrl("settings://display") );

	invokeManager.invoke(request);
}


QVariant BackgroundVideo::getValueFor(QString const& objectName)
{
    QVariant value( m_settings.value(objectName) );

	LOGGER("getValueFor()" << objectName << value);

    return value;
}


void BackgroundVideo::saveValueFor(QString const& objectName, QVariant const& inputValue)
{
	LOGGER("saveValueFor()" << objectName << inputValue);
	m_settings.setValue(objectName, inputValue);
}

}
