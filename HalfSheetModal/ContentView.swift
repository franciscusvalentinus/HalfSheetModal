//
//  ContentView.swift
//  HalfSheetModal
//
//  Created by Franciscus Valentinus Ongkosianbhadra on 18/09/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    @State var showSheet: Bool = false
    var body: some View {
        NavigationView {
            Button {
                showSheet.toggle()
            } label: {
                Text("Present Sheet")
            }
            .navigationTitle("Half Modal Sheet")
            .halfSheet(showSheet: $showSheet) {
                // Your Half Sheet View...
                ZStack {
                    Color.red
                    VStack {
                        Text("Hello iJustine")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        Button {
                            showSheet.toggle()
                        } label: {
                            Text("Close From Sheet")
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
                .ignoresSafeArea()
            } onEnd: {
                print("Dismissed")
            }
        }
    }
}

// Custom Half Sheet Modifier...
extension View {
    
    //Binding Show Variable...
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>, @ViewBuilder sheetView: @escaping ()->SheetView, onEnd: @escaping()->())->some View {
        
        // why we using overlay or background...
        // because it will automatically use the swift ui frame Size only...
        return self
//            .overlay(
//            HalfSheetHelper(sheetView: sheetView())
//            )
            .background(
                HalfSheetHelper(sheetView: sheetView(), showSheet: showSheet, onEnd: onEnd)
            )
    }
}

// UIKit Integration...
struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    
    var sheetView: SheetView
    @Binding var showSheet: Bool
    var onEnd: ()->()
    
    let controller = UIViewController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        controller.view.backgroundColor = .clear
        return controller
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        if showSheet {
            // presenting Modal View...
            
            let sheetController = CustomHostingController(rootView: sheetView)
            sheetController.presentationController?.delegate = context.coordinator
            
            uiViewController.present(sheetController, animated: true)
        }
        else {
            // closing view when showSheet toggled again...
            uiViewController.dismiss(animated: true)
        }
    }
    
    /// On Dismiss...
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        
        var parent: HalfSheetHelper
        
        init(parent: HalfSheetHelper) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onEnd()
        }
    }
}

// Custom UIHostingController for halfSheet...
class CustomHostingController<Content: View>: UIHostingController<Content> {
    
    override func viewDidLoad() {
        
        view.backgroundColor = .clear
        
        //setting presentation controller properties...
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .medium(),
                .large()
            ]
            
            // to show grab protion...
            presentationController.prefersGrabberVisible = true
        }
    }
}
