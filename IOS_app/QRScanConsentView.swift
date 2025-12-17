//
//  QRScanConsentView.swift
//  SwiftUIStarterKitApp
//
//  Created by [Ton Nom] on 14/11/2025.
//  Copyright © 2025 [Ton Entreprise]. All rights reserved.
//

import SwiftUI
import AVFoundation // Pour le scanner QR

// Modèle simple pour les données de consent (tu peux l'adapter à tes mocks)
struct ConsentItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let qrData: String // Données encodées dans le QR pour ce consent
    var isScanned: Bool = false
}

// Mock data pour tester (remplace par ActivitiesMockStore si besoin)
let mockConsents: [ConsentItem] = [
    ConsentItem(title: "Consentement Contrat A", description: "Validation via QR pour contrat standard.", qrData: "consent:A:2025-11-14"),
    ConsentItem(title: "Consentement Contrat B", description: "Validation via QR pour contrat premium.", qrData: "consent:B:2025-11-14")
]

// Vue principale pour le scan QR de consent
struct QRScanConsentView: View {
    @State private var scannedConsents: [ConsentItem] = mockConsents // État pour les consents scannés
    @State private var showScanner = false // Active seulement si dispo
    @State private var showMyQRSheet = false // Sheet pour afficher mon QR code
    @State private var scannedCode: String = "" // Résultat du scan
    @State private var torchIsOn = false // Lampe torche
    @State private var scannerError: String? // Pour afficher erreurs (ex. simu)
    
    // Permissions caméra
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fond dégradé Apple-style (bleu clair à blanc)
                LinearGradient(
                    colors: [.blue.opacity(0.1), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header avec instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scanner un QR Code")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("Pointez la caméra vers le QR pour valider un consentement.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Erreur si scanner indispo (ex. simu)
                    if let error = scannerError {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundStyle(.orange)
                            Text(error)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.yellow.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Liste des consents scannés (en bas, comme un "panier")
                    if !scannedConsents.filter { $0.isScanned }.isEmpty {
                        List {
                            ForEach(scannedConsents.filter { $0.isScanned }) { consent in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text(consent.title)
                                            .font(.headline)
                                        Text(consent.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollDisabled(true)
                        .frame(height: 120)
                    }
                    
                    Spacer()
                    
                    // Bouton pour activer scanner (si pas d'erreur)
                    if scannerError == nil && cameraPermission == .authorized {
                        Button("Démarrer le Scanner") {
                            showScanner = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.blue)
                    }
                }
                
                // Overlay Scanner si activé ET dispo
                if showScanner && scannerError == nil {
                    QRScannerView(
                        scannedCode: $scannedCode,
                        torchIsOn: $torchIsOn
                    )
                    .ignoresSafeArea()
                    .onChange(of: scannedCode) { newCode in
                        handleScanResult(newCode)
                    }
                }
            }
            .navigationTitle("Scan Consent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Bouton haut gauche : Mon QR Code
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showMyQRSheet = true }) {
                        Image(systemName: "qrcode")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("Afficher mon code QR")
                }
                
                // Bouton torche (optionnel, en haut droite)
                ToolbarItem(placement: .topBarTrailing) {
                    if showScanner && scannerError == nil {
                        Button(action: { torchIsOn.toggle() }) {
                            Image(systemName: torchIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
            .sheet(isPresented: $showMyQRSheet) {
                MyQRCodeView(qrData: "my-consent:2025-11-14:user-id") // Remplace par tes données réelles
            }
            .onAppear {
                checkCameraAndDevice()
            }
        }
        .accentColor(.blue) // Style Apple pour les accents
    }
    
    // Fonction pour gérer le résultat du scan
    private func handleScanResult(_ code: String) {
        // Cherche si le code match un consent
        if let matchingConsent = mockConsents.first(where: { $0.qrData == code }) {
            // Marque comme scanné (tu peux ajouter à un store global ici)
            if let index = scannedConsents.firstIndex(where: { $0.id == matchingConsent.id }) {
                scannedConsents[index].isScanned = true
            }
            // Feedback haptique Apple-style
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            // Pause le scanner après scan (optionnel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showScanner = false
            }
        } else {
            // Pas de match : alerte
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        scannedCode = "" // Reset pour prochain scan
    }
    
    // Vérifie les permissions ET la dispo device (fix pour simu)
    @MainActor
    private func checkCameraAndDevice() {
        // Check si on est sur simu (UIDevice.isSimulator)
        #if targetEnvironment(simulator)
        scannerError = "Scanner indisponible sur simulateur. Utilisez un device physique."
        showScanner = false
        print("DEBUG: Running on simulator - QR scanner disabled.")
        return
        #endif
        
        // Check permissions
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermission = granted ? .authorized : .denied
                if granted {
                    self.showScanner = true
                    print("DEBUG: Camera permission granted - Scanner ready.")
                } else {
                    self.scannerError = "Accès caméra refusé. Activez dans Réglages > App."
                    print("DEBUG: Camera permission denied.")
                }
            }
        }
    }
}

// Vue pour le scanner QR (composant réutilisable) - Avec nil guards renforcés
struct QRScannerView: UIViewRepresentable {
    @Binding var scannedCode: String
    @Binding var torchIsOn: Bool
    
    func makeUIView(context: Context) -> UIView {
        let scanner = QRScanner()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let scanner = uiView as? QRScanner else { return }
        scanner.torchIsOn = torchIsOn
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerDelegate {
        var parent: QRScannerView
        
        init(_ parent: QRScannerView) {
            self.parent = parent
        }
        
        func qrScanner(_ scanner: QRScanner, didScan code: String) {
            parent.scannedCode = code
        }
    }
}

// Wrapper UIView pour le scanner (utilise AVFoundation) - Plus de nil checks
class QRScanner: UIView, AVCaptureMetadataOutputObjectsDelegate {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    var torchIsOn = false {
        didSet {
            toggleTorch()
        }
    }
    weak var delegate: QRScannerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScanner()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScanner()
    }
    
    private func setupScanner() {
        // Check device dispo en premier
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("DEBUG: No video capture device available.")
            return
        }
        
        captureSession = AVCaptureSession()
        guard let session = captureSession else { return }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                print("DEBUG: Could not add video input.")
                return
            }
        } catch {
            print("DEBUG: Error creating video input: \(error)")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("DEBUG: Could not add metadata output.")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        guard let layer = previewLayer else { return }
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.layer.addSublayer(layer)
        
        // Start sur main thread pour éviter thread issues
        DispatchQueue.main.async {
            session.startRunning()
            print("DEBUG: QR Scanner session started.")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    private func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = torchIsOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("DEBUG: Torch toggle error: \(error)")
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else { return }
        delegate?.qrScanner(self, didScan: stringValue)
    }
    
    deinit {
        captureSession?.stopRunning()
    }
}

protocol QRScannerDelegate: AnyObject {
    func qrScanner(_ scanner: QRScanner, didScan code: String)
}

// Sheet pour afficher "Mon QR Code" (génère un QR avec Core Image) - Inchangé
struct MyQRCodeView: View {
    let qrData: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Mon Code QR")
                    .font(.title)
                    .fontWeight(.semibold)
                
                // Génère et affiche le QR
                QRCodeGenerator(data: qrData)
                    .frame(width: 200, height: 200)
                
                Text("Partagez ce code pour recevoir des consents.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

// Générateur QR avec Core Image - Inchangé
struct QRCodeGenerator: View {
    let data: String
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            generateQRCode()
        }
    }
    
    private func generateQRCode() {
        guard let data = data.data(using: .ascii) else { return }
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3) // Taille Apple-style
            if let output = filter.outputImage?.transformed(by: transform),
               let cgImage = CIContext().createCGImage(output, from: output.extent) {
                image = UIImage(cgImage: cgImage)
            }
        }
    }
}

// Preview pour Xcode
#Preview {
    QRScanConsentView()
}
