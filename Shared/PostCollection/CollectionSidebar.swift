import SwiftUI

struct CollectionSidebar: View {
    private let collections = postCollections

    var body: some View {
        List {
            ForEach(collections) { collection in
                NavigationLink(
                    destination: PostList(selectedCollection: collection)
                ) {
                    Text(collection.title)
                }
            }
        }
        .navigationTitle("Collections")
        .listStyle(SidebarListStyle())
    }
}

struct CollectionSidebar_Previews: PreviewProvider {
    static var previews: some View {
        CollectionSidebar()
    }
}