import SwiftUI

struct AlertSheetView: View {
    @Binding var error: Error?
    @EnvironmentObject var viewController: MainViewController
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(nsImage: NSImage(named: NSImage.cautionName)!)
                    .resizable().frame(width: 70, height: 70)
                VStack(alignment: .leading) {
                    Text("Sorry, an error occurred.").bold()
                        .padding(.bottom)
                        .lineLimit(nil)
                        .frame(maxHeight: .infinity)
                    if error != nil { Text(error!.localizedDescription) }
                }
            }
            HStack {
                Spacer()
                Button("OK") { error = nil }
            }
        }.padding()
    }
}

struct AlertSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let error = NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoSuchFileError)
        return AlertSheetView(error: Binding.constant(error)).environmentObject(MainViewController())
    }
}
