#ifndef BackgroundVideo_HPP_
#define BackgroundVideo_HPP_

#include <bb/system/InvokeManager>

#include "customsqldatasource.h"
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

    CustomSqlDataSource m_sql;
    bb::system::InvokeManager m_invokeManager;
    LazySceneCover m_cover;
    LazyMediaPlayer m_player;
    Persistance m_persistance;

    BackgroundVideo(Application* app);
    QObject* loadRoot(QString const& qml, bool invoked=false);

signals:
	void initialize();

private slots:
	void init();
	void invoked(bb::system::InvokeRequest const& request);
	void hackPlayback();
	void aboutToQuit();

public:
    static void create(Application *app);
    virtual ~BackgroundVideo() {}
    Q_INVOKABLE void invokeSettingsApp();
    Q_INVOKABLE void addBookmark(QVariant position=QVariant(), QString const& body=QString());
    Q_INVOKABLE void fetchAllBookmarks();
    Q_INVOKABLE void fetchAllRecent();
    Q_INVOKABLE void deleteBookmark(int id);
    Q_INVOKABLE void deleteRecent(QString const& file);
};

}

#endif /* BackgroundVideo_HPP_ */
