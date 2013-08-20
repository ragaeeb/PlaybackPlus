#ifndef BackgroundVideo_HPP_
#define BackgroundVideo_HPP_

#include "Persistance.h"

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

    Persistance m_persistance;
    NavigationPane* m_root;

    BackgroundVideo(Application* app);

private slots:
	void onMostRecentTriggered();
	void onClearRecentTriggered();
	void settingChanged(QString const& key);

public:
    static void create(Application *app);
    virtual ~BackgroundVideo() {}
    Q_INVOKABLE void invokeSettingsApp();
};

}

#endif /* BackgroundVideo_HPP_ */
