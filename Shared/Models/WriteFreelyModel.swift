import Foundation
import WriteFreely
import Security
import Network

// MARK: - WriteFreelyModel

final class WriteFreelyModel: ObservableObject {
    @Published var account = AccountModel()
    @Published var preferences = PreferencesModel()
    @Published var posts = PostListModel()
    @Published var editor = PostEditorModel()
    @Published var isLoggingIn: Bool = false
    @Published var isProcessingRequest: Bool = false
    @Published var hasNetworkConnection: Bool = true
    @Published var selectedPost: WFAPost?
    @Published var selectedCollection: WFACollection?
    @Published var showAllPosts: Bool = true
    @Published var isPresentingDeleteAlert: Bool = false
    @Published var shouldHandleError: Bool = false
    @Published var isPresentingNetworkErrorAlert: Bool = false
    @Published var postToDelete: WFAPost?
    #if os(iOS)
    @Published var isPresentingSettingsView: Bool = false
    #endif

    static var shared = WriteFreelyModel()

    var currentError: Error? {
        didSet {
            self.shouldHandleError = currentError != nil
        }
    }

    // swiftlint:disable line_length
    let helpURL = URL(string: "https://discuss.write.as/c/help/5")!
    let howToURL = URL(string: "https://discuss.write.as/t/using-the-writefreely-ios-app/1946")!
    let reviewURL = URL(string: "https://apps.apple.com/app/id1531530896?action=write-review")!
    let licensesURL = URL(string: "https://github.com/writeas/writefreely-swiftui-multiplatform/tree/main/Shared/Resources/Licenses")!
    // swiftlint:enable line_length

    internal var client: WFClient?
    private let defaults = UserDefaults.shared
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    internal var postToUpdate: WFAPost?

    init() {
        DispatchQueue.main.async {
            self.preferences.appearance = self.defaults.integer(forKey: WFDefaults.colorSchemeIntegerKey)
            self.preferences.font = self.defaults.integer(forKey: WFDefaults.defaultFontIntegerKey)
            self.account.restoreState()
            if self.account.isLoggedIn {
                guard let serverURL = URL(string: self.account.server) else {
                    print("Server URL not found")
                    return
                }
                do {
                    guard let token = try self.fetchTokenFromKeychain(
                            username: self.account.username,
                            server: self.account.server
                    ) else {
                        self.currentError = AccountError.couldNotFetchTokenFromKeychain
                        return
                    }

                    self.account.login(WFUser(token: token, username: self.account.username))
                    self.client = WFClient(for: serverURL)
                    self.client?.user = self.account.user
                    self.fetchUserCollections()
                    self.fetchUserPosts()
                } catch {
                    self.currentError = AccountError.couldNotFetchTokenFromKeychain
                }
            }
        }

        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.hasNetworkConnection = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
