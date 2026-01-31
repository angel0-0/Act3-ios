import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar la vista del juego
        if let view = self.view as! SKView? {
            // Crear la escena del juego
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            // Presentar la escena
            view.presentScene(scene)
            
            // Configuraciones de depuración (puedes desactivarlas después)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait // Solo modo vertical
    }

    override var prefersStatusBarHidden: Bool {
        return true // Ocultar la barra de estado
    }
}
