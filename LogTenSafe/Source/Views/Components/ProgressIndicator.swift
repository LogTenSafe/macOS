import SwiftUI
import AppKit

struct ProgressIndicator: NSViewRepresentable {
    var style: NSProgressIndicator.Style = .bar
    var fractionCompleted = 0.0
    var isIndeterminate = false
    
    func makeNSView(context: NSViewRepresentableContext<ProgressIndicator>) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        indicator.minValue = 0
        indicator.maxValue = 1
        indicator.startAnimation(nil)
        //indicator.controlTint = . blueControlTint
        return indicator
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ProgressIndicator>) {
        nsView.style = style
        nsView.doubleValue = fractionCompleted
        nsView.isIndeterminate = isIndeterminate
    }
}

struct ProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressIndicator(style: .bar, fractionCompleted: 0.3)
            ProgressIndicator(style: .spinning, isIndeterminate: true)
        }
    }
}
