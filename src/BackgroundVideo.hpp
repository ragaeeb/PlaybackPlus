#ifndef BackgroundVideo_HPP_
#define BackgroundVideo_HPP_

#include "LazyMediaPlayer.h"
#include "LazySceneCover.h"
#include "Persistance.h"

namespace bb {
	namespace cascades {
		class Application;
		class NavigationPane;
	}
}

namespace backgroundvideo {

using namespace bb::cascades;
using namespace canadainc;

class BackgroundVideo : public QObject
{
    Q_OBJECT

    LazySceneCover m_cover;
    LazyMediaPlayer m_player;
    Persistance m_persistance;
    NavigationPane* m_root;

    BackgroundVideo(Application* app);

signals:
	void initialize();

private slots:
	void settingChanged(QString const& key);
	void init();

public:
    static void create(Application *app);
    virtual ~BackgroundVideo() {}
    Q_INVOKABLE void invokeSettingsApp();
};

}

#endif /* BackgroundVideo_HPP_ */
