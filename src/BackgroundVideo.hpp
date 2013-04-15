#ifndef BackgroundVideo_HPP_
#define BackgroundVideo_HPP_

#include "Persistance.h"
#include "SmsManager.h"

namespace bb {
	namespace cascades {
		class Application;
		class NavigationPane;
	}
}

namespace backgroundvideo {

using namespace bb::cascades;
using namespace bb::pim::message;
using namespace canadainc;

class BackgroundVideo : public QObject
{
    Q_OBJECT

    SmsManager m_sms;
    Persistance m_persistance;
    NavigationPane* m_root;

    BackgroundVideo(Application* app);

private slots:
	void onMostRecentTriggered();
	void onClearRecentTriggered();
	void smsReceived(Message const& m, QString const& conversationKey);
	void toastFinished(bool buttonTriggered);
	void settingChanged(QString const& key);

public:
    static void create(Application *app);
    virtual ~BackgroundVideo() {}
    Q_INVOKABLE void invokeSettingsApp();
};

}

#endif /* BackgroundVideo_HPP_ */
