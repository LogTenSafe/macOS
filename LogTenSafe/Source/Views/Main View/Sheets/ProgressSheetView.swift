import SwiftUI

struct ProgressSheetView: View {
    var prompt: String
    var progress: Progress
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(prompt)
            ProgressIndicator(fractionCompleted: progress.fractionCompleted, isIndeterminate: progress.isIndeterminate)
            }.padding()
            .frame(minWidth: 300)
    }
}

struct ProgressSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressSheetView(prompt: "Restoring backup…", progress: Progress())
    }
}
