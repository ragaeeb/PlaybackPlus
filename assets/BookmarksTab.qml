import bb.cascades 1.0
import bb.system 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    signal bookmarkSelected(string file, int position);
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        titleBar: TitleBar {
            title: qsTr("Bookmarks") + Retranslate.onLanguageChanged
        }
        
        actions: [
            InvokeActionItem {
                id: iai
                title: qsTr("Share") + Retranslate.onLanguageChanged
                enabled: !noElements.visible
                
                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }
                
                onTriggered: {
                    persist.showBlockingToast( qsTr("Note that BBM has a maximum limit for the length of text that can be inputted into the message field. So if your conversation is too big it may not paste properly.\n\nIf you want to save the data to a file, consider downloading our 'Exporter' app for BlackBerry 10."), qsTr("OK") );
                    iai.data = persist.convertToUtf8( app.exportAllBookmarks(adm) );
                }
                
                ActionBar.placement: ActionBarPlacement.OnBar
            },
            
            DeleteActionItem {
                title: qsTr("Clear All") + Retranslate.onLanguageChanged
                imageSource: "images/ic_bookmark_delete.png"
                
                onTriggered: {
                    prompt.show();
                }
                
                attachedObjects: [
                    SystemDialog {
                        id: prompt
                        title: qsTr("Confirmation") + Retranslate.onLanguageChanged
                        body: qsTr("Are you sure you want to clear all the bookmarks?") + Retranslate.onLanguageChanged
                        confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged
                        cancelButton.label: qsTr("Cancel") + Retranslate.onLanguageChanged
                        
                        onFinished: {
                            if (result == SystemUiResult.ConfirmButtonSelection) {
                                app.clearAllBookmarks();
                                persist.showToast( qsTr("Cleared all bookmarks!") );
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
                text: qsTr("You have no media that you have bookmarked in Playback Plus.") + Retranslate.onLanguageChanged
                visible: false
            }
            
            ListView
            {
                id: listView
                property alias formatter: textUtils
                property alias activeImage: activePaint
                
                verticalAlignment: VerticalAlignment.Fill
                horizontalAlignment: HorizontalAlignment.Fill
                
                dataModel: GroupDataModel {
                    id: adm
                    sortingKeys: ["file", "position"]
                    grouping: ItemGrouping.ByFullValue
                }
                
                function removeBookmark(ListItemData) {
                    app.deleteBookmark(ListItemData.id);
                }
                
                listItemComponents:
                [
                    ListItemComponent {
                        type: "header"
                        
                        Header {
                            title: {
                                var uri = ListItemData;
                                uri = uri.substring( uri.lastIndexOf("/")+1 );
                                uri = uri.substring( 0, uri.lastIndexOf(".") );
                                
                                return uri;
                            }

                            subtitle: ListItem.view.dataModel.childCount(ListItem.indexPath)
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        Container
                        {
                            id: rootItem
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            background: ListItem.active || ListItem.selected ? ListItem.view.activeImage.imagePaint : undefined
                            
                            Container {
                                horizontalAlignment: HorizontalAlignment.Fill
                                topPadding: 5
                                bottomPadding: 5
                                leftPadding: 5
                                
                                layout: StackLayout {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                
                                Label {
                                    id: labelField
                                    text: {
                                        var position = rootItem.ListItem.view.formatter.formatTime(ListItemData.position);
                                        
                                        if (ListItemData.body && ListItemData.body.length > 0) {
                                            "%1: %2".arg(position).arg(ListItemData.body);
                                        } else {
                                            return position;
                                        }
                                    }
                                    
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    textStyle.fontSize: FontSize.XXSmall
                                    textStyle.color: Color.White
                                    textStyle.fontWeight: FontWeight.Bold
                                    multiline: true
                                    
                                    layoutProperties: StackLayoutProperties {
                                        spaceQuota: 1
                                    }
                                }
                            }
                            
                            Divider {
                                topMargin: 0; bottomMargin: 0;
                            }
                            
                            contextActions: [
                                ActionSet {
                                    title: labelField.text
                                    subtitle: rootItem.ListItem.view.formatter.formatTime(ListItemData.position)
                                    
                                    DeleteActionItem {
                                        title: qsTr("Remove") + Retranslate.onLanguageChanged
                                        imageSource: "images/ic_bookmark_delete.png"
                                        
                                        onTriggered: {
                                            rootItem.ListItem.view.removeBookmark(ListItemData);
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                onTriggered: {
                    var data = dataModel.data(indexPath);
                    bookmarkSelected(data.file, data.position);
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchBookmarks) {
                        adm.clear();
                        adm.insertList(data);
                        
                        noElements.visible = data.length == 0;
                    }
                }
                
                onCreationCompleted: {
                    sql.dataLoaded.connect(onDataLoaded);
                    console.log("forcing fetch all bookmarks!!!");
                    app.fetchAllBookmarks(true);
                }
                
                attachedObjects: [
                    TextUtils {
                        id: textUtils
                    },
                    
                    ImagePaintDefinition {
                        id: activePaint
                        imageSource: "images/listitem_active.amd"
                    }
                ]
            }
        }
    }
}