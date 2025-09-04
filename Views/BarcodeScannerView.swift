//
//  BarcodeScannerView.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import SwiftUI

#if os(iOS)
import VisionKit
#endif

struct BarcodeScannerView: View {
    let onBarcodeScanned: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingScanner = false
    @State private var scannedBarcode: String?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            NavigationStack {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Scanner Status Section
                    scannerStatusSection
                    
                    // Action Buttons Section
                    actionButtonsSection
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .navigationTitle("Barcode Scanner")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showingScanner) {
                    #if os(iOS)
                    DataScannerRepresentable { barcode in
                        handleBarcodeScanned(barcode)
                    }
                    #endif
                }
                .alert("Scanner Error", isPresented: $showingError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var headerSection: some View {
        GlassmorphismCard {
            VStack(spacing: 20) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 70))
                    .foregroundColor(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 12) {
                    Text("Scan Product Barcode")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text("Point your camera at a product barcode to automatically fill in product details")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var scannerStatusSection: some View {
        GlassmorphismCard {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text("Scanner Status")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                #if os(iOS)
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Scanner Available")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Your device supports barcode scanning")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                } else {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Scanner Unavailable")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Barcode scanning is not supported on this device")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                #else
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iOS Only Feature")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Barcode scanning is only available on iOS devices")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
                #endif
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            #if os(iOS)
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                AnimatedGradientButton(title: "Start Scanning", icon: "camera.fill") {
                    showingScanner = true
                }
            } else {
                AnimatedGradientButton(title: "Scanner Unavailable", icon: "xmark.circle", isPrimary: false) {
                    // Do nothing
                }
                .disabled(true)
            }
            #else
            AnimatedGradientButton(title: "iOS Only Feature", icon: "iphone", isPrimary: false) {
                // Do nothing
            }
            .disabled(true)
            #endif
            
            if let barcode = scannedBarcode {
                VStack(spacing: 12) {
                    Text("Scanned Barcode:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(barcode)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    
                    AnimatedGradientButton(title: "Use This Barcode", icon: "checkmark.circle.fill") {
                        onBarcodeScanned(barcode)
                        dismiss()
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6).opacity(0.5))
                )
            }
        }
    }
    
    private func handleBarcodeScanned(_ barcode: String) {
        scannedBarcode = barcode
        showingScanner = false
    }
}

#if os(iOS)
struct DataScannerRepresentable: UIViewControllerRepresentable {
    let onBarcodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeScanned: onBarcodeScanned)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onBarcodeScanned: (String) -> Void
        
        init(onBarcodeScanned: @escaping (String) -> Void) {
            self.onBarcodeScanned = onBarcodeScanned
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                if let payload = barcode.payloadStringValue {
                    onBarcodeScanned(payload)
                }
            default:
                break
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addedItems {
                switch item {
                case .barcode(let barcode):
                    if let payload = barcode.payloadStringValue {
                        onBarcodeScanned(payload)
                    }
                default:
                    break
                }
            }
        }
    }
}
#endif

#Preview {
    BarcodeScannerView { barcode in
        print("Scanned: \(barcode)")
    }
}
