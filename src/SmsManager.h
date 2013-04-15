#ifndef SMSMANAGER_H_
#define SMSMANAGER_H_

#include <QObject>

#include <bb/pim/account/Account>
#include <bb/pim/message/Keys>

namespace bb {
	namespace pim {
		namespace message {
			class Message;
			class MessageService;
		}
	}
}

namespace canadainc {

using namespace bb::pim::message;

class SmsManager : public QObject
{
	Q_OBJECT

	Q_PROPERTY(qreal monitoringIncomingSms READ monitoringIncomingSms NOTIFY monitoringStateChanged)

	MessageService* m_ms;
    qint64 m_accountKey;
    bool m_connected;

private slots:
    void messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey);

Q_SIGNALS:
	void monitoringStateChanged();
	void smsReceived(Message const& m, QString const& conversationKey);

public:
	SmsManager(QObject* parent=NULL);
	virtual ~SmsManager();

	bool monitorIncomingSMS(bool monitor);
	bool monitoringIncomingSms() const;
	void sendMessage(Message const& m, QString const& ck, QString const& text);
	void markRead(MessageKey mk);
};

} /* namespace canadainc */
#endif /* SMSMANAGER_H_ */
