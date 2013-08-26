import bb.cascades 1.0
import bb.system 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    signal recentSelected(string file, int position);
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        titleBar: TitleBar {
            title: qsTr("Recent") + Retranslate.onLanguageChanged
        }
        
        actions: [
            DeleteActionItem {
                title: qsTr("Clear Recent") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    prompt.show();
                }
                
                attachedObjects: [
                    SystemDialog {
                        id: prompt
                        title: qsTr("Confirmation") + Retranslate.onLanguageChanged
                        body: qsTr("Are you sure you want to clear all recent items?") + Retranslate.onLanguageChanged
                        confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged
                        cancelButton.label: qsTr("Cancel") + Retranslate.onLanguageChanged
                        
                        onFinished: {
                            if (result == SystemUiResult.ConfirmButtonSelection) {
                                sql.query = "DELETE from recent";
                                sql.load(2);
                                listView.reload();
                                
                                persist.showToast( qsTr("Cleared recent list!") );
                            }
                        }
                    }
                ]
            }
        ]
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            topPadding: noElements.visible ? 20 : 0
            bottomPadding: topPadding; rightPadding: topPadding; leftPadding: topPadding
            
            Label {
                id: noElements
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                textStyle.textAlign: TextAlign.Center
                multiline: true
                text: qsTr("You have no media that you have recently played in Playback Plus.") + Retranslate.onLanguageChanged
                visible: false
            }
            
            ListView
            {
                id: listView
                property alias formatter: textUtils
                
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Fill
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function removeRecent(ListItemData)
                {
                    sql.query = "DELETE FROM recent WHERE file=?";
                    var params = [ListItemData.file];
                    sql.executePrepared(params, 18);
                    reload();
                }
                
                listItemComponents:
                [
                    ListItemComponent
                    {
                        StandardListItem {
                            id: sli
                            imageSource: "images/ic_open_recent.png";
                            status: ListItem.view.formatter.formatTime(ListItemData.position)
                            description: {
                                var uri = ListItemData.file;
                                uri = uri.substring( uri.lastIndexOf("/")+1 );
                                uri = uri.substring( 0, uri.lastIndexOf(".") );
                                
                                return uri;
                            }
                            
                            contextActions: [
                                ActionSet {
                                    title: sli.description
                                    subtitle: sli.status
                                    
                                    DeleteActionItem {
                                        title: qsTr("Remove") + Retranslate.onLanguageChanged
                                        imageSource: "images/ic_clear_recent.png"
                                        
                                        onTriggered: {
                                            sli.ListItem.view.removeRecent(ListItemData);
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                onTriggered: {
                    var data = dataModel.data(indexPath);
                    recentSelected(data.file, data.position);
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == 1) {
                        adm.clear();
                        adm.append(data);
                        
                        noElements.visible = data.length == 0;
                    }
                }
                
                function reload()
                {
                    sql.dataLoaded.connect(onDataLoaded);
                    sql.query = "SELECT * from recent ORDER BY timestamp DESC LIMIT 10";
                    sql.load(1);                    
                }
                
                onCreationCompleted: {
                    reload();
                }
                
                attachedObjects: [
                    TextUtils {
                        id: textUtils
                    }
                ]
            }
        }
    }
}