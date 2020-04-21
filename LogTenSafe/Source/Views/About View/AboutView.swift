import SwiftUI

struct AboutView: View {
    private var licenses: Array<(String, URL)> = [
        ("Alamofire", URL(string: "https://github.com/Alamofire/Alamofire/blob/master/LICENSE")!),
        ("Checksum", URL(string: "https://github.com/rnine/Checksum/blob/develop/LICENSE.md")!),
        ("Defaults", URL(string: "https://github.com/sindresorhus/Defaults/blob/master/license")!),
        ("Jekyll Apple Help", URL(string: "https://github.com/chuckhoupt/jekyll-apple-help/blob/master/LICENSE")!)
    ]
    
    var body: some View {
        VStack {
            Image("Icon").resizable().frame(width: 64, height: 64)
            Text(Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String).bold()
            Text(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                .padding(.bottom)
            Text(Bundle.main.infoDictionary!["NSHumanReadableCopyright"] as! String)
                .controlSize(.small).lineLimit(nil)
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 3) {
                ForEach(licenses.indices) { index in
                    HStack(spacing: 0) {
                        Text("This application uses the open-source \(self.licenses[index].0) library. ")
                        Button("More information") { self.visit(self.licenses[index].1) }
                            .buttonStyle(BorderlessButtonStyle())
                            .foregroundColor(.blue)
                    }.controlSize(.small)
                }
            }
        }.padding()
            .frame(minWidth: 460, minHeight: 255)
    }
    
    private func visit(_ URL: URL) {
        NSWorkspace.shared.open(URL)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
