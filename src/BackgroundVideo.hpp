#ifndef BackgroundVideo_HPP_
#define BackgroundVideo_HPP_

#include <QSettings>

#include <bb/pim/account/Account>
#include <bb/pim/message/Keys>

#include <bb/system/SystemUiResult>

namespace bb {
	namespace cascades {
		class Application;
		class NavigationPane;
	}

	namespace pim {
		namespace message {
			class MessageService;
		}
	}
}

namespace backgroundvideo {

using namespace bb::cascades;
using namespace bb::pim::message;
using namespace bb::pim::account;

class BackgroundVideo : public QObject
{
    Q_OBJECT

    NavigationPane* m_root;
    QSettings m_settings;
    AccountKey m_accountKey;
    MessageService* m_ms;
    bool m_connected;

    BackgroundVideo(Application* app);

private slots:
	void onMostRecentTriggered();
	void onClearRecentTriggered();
    void messageAdded(bb::pim::account::AccountKey, bb::pim::message::ConversationKey, bb::pim::message::MessageKey);
    void finished(bb::system::SystemUiResult::Type value);

public:
    static void create(Application *app);
    virtual ~BackgroundVideo() {}
    Q_INVOKABLE void invokeSettingsApp();
    Q_INVOKABLE void saveValueFor(QString const& objectName, QVariant const& inputValue);
    Q_INVOKABLE QVariant getValueFor(QString const& objectName);
    Q_INVOKABLE void monitorSMS(bool const& value);
};

}

#endif /* BackgroundVideo_HPP_ */
