import SwiftUI

struct PostEditorView: View {
    private let bodyLineSpacing: CGFloat = 17 * 0.5
    @EnvironmentObject var model: WriteFreelyModel

    @ObservedObject var post: WFAPost
    @State private var isHovering: Bool = false
    @State private var updatingTitleFromServer: Bool = false
    @State private var updatingBodyFromServer: Bool = false

    var body: some View {
        VStack {
            switch post.appearance {
            case "sans":
                TextField("Title (optional)", text: $post.title)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 4)
                    .padding(.bottom)
                    .font(.custom("OpenSans-Regular", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                            post.status = PostStatus.edited.rawValue
                        }
                        if updatingTitleFromServer {
                            updatingTitleFromServer = false
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .font(.custom("OpenSans-Regular", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("OpenSans-Regular", size: 17, relativeTo: Font.TextStyle.body))
                        .lineSpacing(bodyLineSpacing)
                        .opacity(post.body.count == 0 && !isHovering ? 0.0 : 1.0)
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue && !updatingBodyFromServer {
                                post.status = PostStatus.edited.rawValue
                            }
                            if updatingBodyFromServer {
                                updatingBodyFromServer = false
                            }
                        }
                        .onHover(perform: { hovering in
                            self.isHovering = hovering
                        })
                }
                .background(Color(NSColor.controlBackgroundColor))
            case "wrap", "mono", "code":
                TextField("Title (optional)", text: $post.title)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 4)
                    .padding(.bottom)
                    .font(.custom("Hack", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                            post.status = PostStatus.edited.rawValue
                        }
                        if updatingTitleFromServer {
                            updatingTitleFromServer = false
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .font(.custom("Hack", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("Hack", size: 17, relativeTo: Font.TextStyle.body))
                        .lineSpacing(bodyLineSpacing)
                        .opacity(post.body.count == 0 && !isHovering ? 0.0 : 1.0)
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue && !updatingBodyFromServer {
                                post.status = PostStatus.edited.rawValue
                            }
                            if updatingBodyFromServer {
                                updatingBodyFromServer = false
                            }
                        }
                        .onHover(perform: { hovering in
                            self.isHovering = hovering
                        })
                }
                .background(Color(NSColor.controlBackgroundColor))
            default:
                TextField("Title (optional)", text: $post.title)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 4)
                    .padding(.bottom)
                    .font(.custom("Lora", size: 26, relativeTo: Font.TextStyle.largeTitle))
                    .onChange(of: post.title) { _ in
                        if post.status == PostStatus.published.rawValue && !updatingTitleFromServer {
                            post.status = PostStatus.edited.rawValue
                        }
                        if updatingTitleFromServer {
                            updatingTitleFromServer = false
                        }
                    }
                ZStack(alignment: .topLeading) {
                    if post.body.count == 0 {
                        Text("Write...")
                            .foregroundColor(Color(NSColor.placeholderTextColor))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .font(.custom("Lora", size: 17, relativeTo: Font.TextStyle.body))
                    }
                    TextEditor(text: $post.body)
                        .font(.custom("Lora", size: 17, relativeTo: Font.TextStyle.body))
                        .lineSpacing(bodyLineSpacing)
                        .opacity(post.body.count == 0 && !isHovering ? 0.0 : 1.0)
                        .onChange(of: post.body) { _ in
                            if post.status == PostStatus.published.rawValue && !updatingBodyFromServer {
                                post.status = PostStatus.edited.rawValue
                            }
                            if updatingBodyFromServer {
                                updatingBodyFromServer = false
                            }
                        }
                        .onHover(perform: { hovering in
                            self.isHovering = hovering
                        })
                }
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .padding()
        .background(Color.white)
        .toolbar {
            ToolbarItem(placement: .status) {
                PostEditorStatusToolbarView(post: post)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    if model.account.isLoggedIn {
                        publishPost()
                    } else {
                        let mainMenu = NSApplication.shared.mainMenu
                        let appMenuItem = mainMenu?.item(withTitle: "WriteFreely")
                        let prefsItem = appMenuItem?.submenu?.item(withTitle: "Preferences…")
                        NSApplication.shared.sendAction(prefsItem!.action!, to: prefsItem?.target, from: nil)
                    }
                }, label: {
                    Image(systemName: "paperplane")
                })
                .disabled(post.status == PostStatus.published.rawValue || || post.body.count == 0)
            }
        }
        .onChange(of: post.hasNewerRemoteCopy, perform: { _ in
            if post.status == PostStatus.edited.rawValue && !post.hasNewerRemoteCopy {
                post.status = PostStatus.published.rawValue
            }
        })
        .onChange(of: post.status, perform: { _ in
            if post.status != PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    model.editor.setLastDraft(post)
                }
            } else {
                DispatchQueue.main.async {
                    model.editor.clearLastDraft()
                }
            }
        })
        .onDisappear(perform: {
            if post.title.count == 0
                && post.body.count == 0
                && post.status == PostStatus.local.rawValue
                && post.updatedDate == nil
                && post.postId == nil {
                DispatchQueue.main.async {
                    model.posts.remove(post)
                    model.posts.loadCachedPosts()
                }
            } else if post.status != PostStatus.published.rawValue {
                DispatchQueue.main.async {
                    LocalStorageManager().saveContext()
                }
            }
        })
    }

    private func publishPost() {
        DispatchQueue.main.async {
            LocalStorageManager().saveContext()
            model.posts.loadCachedPosts()
            model.publish(post: post)
        }
    }
}

struct PostEditorView_EmptyPostPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let testPost = WFAPost(context: context)
        testPost.createdDate = Date()
        testPost.appearance = "norm"

        let model = WriteFreelyModel()

        return PostEditorView(post: testPost)
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}

struct PostEditorView_ExistingPostPreviews: PreviewProvider {
    static var previews: some View {
        let context = LocalStorageManager.persistentContainer.viewContext
        let testPost = WFAPost(context: context)
        testPost.title = "Test Post Title"
        testPost.body = "Here's some cool sample body text."
        testPost.createdDate = Date()
        testPost.appearance = "code"

        let model = WriteFreelyModel()

        return PostEditorView(post: testPost)
            .environment(\.managedObjectContext, context)
            .environmentObject(model)
    }
}
