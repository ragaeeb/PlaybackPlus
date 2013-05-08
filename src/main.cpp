#include "precompiled.h"

#include "Logger.h"
#include "BackgroundVideo.hpp"

using namespace bb::cascades;
using namespace backgroundvideo;

#ifdef DEBUG
namespace {

void redirectedMessageOutput(QtMsgType type, const char *msg) {
	Q_UNUSED(type);
	fprintf(stderr, "%s\n", msg);
}

}
#endif

Q_DECL_EXPORT int main(int argc, char **argv)
{
#ifdef DEBUG
	qInstallMsgHandler(redirectedMessageOutput);
#endif

	qmlRegisterType<bb::cascades::pickers::FilePicker>("CustomComponent", 1, 0, "FilePicker");
	qmlRegisterUncreatableType<bb::cascades::pickers::FileType>("CustomComponent", 1, 0, "FileType", "Can't instantiate");
	qmlRegisterUncreatableType<bb::cascades::pickers::FilePickerMode>("CustomComponent", 1, 0, "FilePickerMode", "Can't instantiate");
    qmlRegisterType<QTimer>("CustomComponent", 1, 0, "QTimer");
    qmlRegisterType<bb::device::DisplayInfo>("CustomComponent", 1, 0, "DisplayInfo");

    Application app(argc, argv);
    BackgroundVideo::create(&app);

    return Application::exec();
}
