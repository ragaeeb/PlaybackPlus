#include "precompiled.h"

#include "SmsManager.h"
#include "Logger.h"

namespace canadainc {

using namespace bb::pim::account;
using namespace bb::pim::message;

SmsManager::SmsManager(QObject* parent) : QObject(parent), m_ms(NULL), m_accountKey(0), m_connected(false)
{
}


bool SmsManager::monitorIncomingSMS(bool monitor)
{
	if (!m_accountKey)
	{
	    AccountService as;

	    QList<Account> accounts = as.accounts(Service::Messages, "sms-mms");

	    if ( !accounts.isEmpty() ) {
	    	m_accountKey = accounts.first().id();
	    	LOGGER("Instantiate new message service & LED" << m_accountKey);
		    LOGGER("Message Service & LED service created");
	    } else {
	    	LOGGER("ERROR, could not access SMS service!");
	    }
	}

	if (monitor && !m_connected)
	{
	    if (m_accountKey) {
	    	LOGGER("Connecting to messageAdded signal");

	    	if (m_ms == NULL) {
	    		m_ms = new MessageService(this);
	    	}

	    	m_connected = connect( m_ms, SIGNAL( messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey) ), this, SLOT( messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey) ) );
	    	emit monitoringStateChanged();
	    }
	} else if (!monitor & m_connected) {
		LOGGER("Disconnected");
		disconnect( m_ms, SIGNAL( messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey) ), this, SLOT( messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey) ) );
		m_connected = false;
		emit monitoringStateChanged();
	}

	return m_connected;
}


void SmsManager::markRead(MessageKey mk)
{
	LOGGER("Button selection, marking as read" << m_accountKey << mk);
	m_ms->markRead(m_accountKey, mk);
}


bool SmsManager::monitoringIncomingSms() const {
	return m_connected;
}


void SmsManager::sendMessage(Message const& m, QString const& ck, QString const& text)
{
	MessageBuilder* mb = MessageBuilder::create(m_accountKey);
	mb->addRecipient( m.sender() );
	mb->conversationId(ck);
	mb->body( MessageBody::PlainText, text.toUtf8() );
	mb->addAttachment( Attachment("text/plain", "<primary_text.txt>", text) );

	LOGGER("Replying with" << m.sender().displayableName() << ck << text);

	Message reply = *mb;
	m_ms->send(m_accountKey, reply);

	LOGGER("Sent, now deleting messagebuilder");

	delete mb;
}


void SmsManager::messageAdded(bb::pim::account::AccountKey ak, bb::pim::message::ConversationKey ck, bb::pim::message::MessageKey mk)
{
	Q_UNUSED(ck);

	LOGGER("messageAdded()");

	if (ak == m_accountKey)
	{
		LOGGER("SMS messageAdded()");

		Message m = m_ms->message(ak, mk);

		if ( m.isInbound() && m.attachmentCount() > 0 && ( m.attachmentAt(0).mimeType() == "text/plain" ) )
		{
			LOGGER("SMS Inbound");
			emit smsReceived(m, ck);
		}
	}
}


SmsManager::~SmsManager()
{
}

} /* namespace canadainc */
