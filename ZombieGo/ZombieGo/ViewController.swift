//
//  ViewController.swift
//  ZombieGo
//
//  Created by Lo Howard on 7/8/19.
//  Copyright © 2019 Lo Howard. All rights reserved.
//

import UIKit
import ARKit
import AVFoundation

enum BitMaskCategory: Int {
    case bullet = 2
    case target = 3
}

class ViewController: UIViewController, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    var numberOfBullets = 10
    
    var power: Float = 50
    
    var zombieHealth = randomNumber(lowerBound: 3, upperBound: 8)
    
    var Target: SCNNode?
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    var selectedItem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        gunSpawn()
        self.sceneView.autoenablesDefaultLighting = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(gestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self
        self.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            numberOfBullets = 10
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView, let pov = sceneView.pointOfView else { return }
        let transform = pov.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power), asImpulse: true)
        bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        
        if numberOfBullets > 0 {
            self.sceneView.scene.rootNode.addChildNode(bullet)
            numberOfBullets -= 1
            bullet.runAction(SCNAction.sequence([SCNAction.wait(duration: 2.0), SCNAction.removeFromParentNode()]))
        } else {
            bullet.removeAllActions()
        }
    }
    
    @IBAction func addZombie(_ sender: Any) {
        //        spawnZombies(fileName: "WWZombie.scnassets/Zombie Running.scn", childNode: "WorldWar_zombie")
        //        spawnZombies(fileName: "WomanZombie.scnassets/JillRunning.scn", childNode: "Jill")
        //        spawnZombies(fileName: "WomanZombie.scnassets/ZombieWalk.scn", childNode: "ZombieGirl_Body")
        //        spawnZombies(fileName: "ClownZombie.scnassets/Zombie Running.scn", childNode: "WhiteClown")
//        spawnZombies(fileName: "PrisonerZombie.scnassets/prisonerzombiewalking.scn", childNode: "Prisoner", spawnSeconds: randomNumber(lowerBound: 1, upperBound: 3))
        //        spawnZombies(fileName: "SurvivorZombie.scnassets/Zombie Running.scn", childNode: "Survivor")
        //        spawnZombies(fileName: "SurvivorZombie.scnassets/Zombie Crawl.scn", childNode: "Zombie")
        //        spawnZombies(fileName: "CopZombie.scnassets/CopWalking.scn", childNode: "Cop")
        spawnZombies(fileName: "CopZombie.scnassets/CopWalking.scn", childNode: "Cop", spawnSeconds: randomNumber(lowerBound: 1, upperBound: 3))
//        spawnZombies(fileName: "GirlScoutZombie.scnassets/Zombie Walk.scn", childNode: "GirlScout", spawnSeconds: randomNumber(lowerBound: 1, upperBound: 4))
        //        playZombieSound()
    }
    
    func spawnZombies(fileName: String, childNode: String, spawnSeconds: Int) {
        let test = SCNMaterial()
        test.diffuse.contents = UIImage(named: "CopZombie.scnassets/FuzZombie__diffuse.png")
        test.locksAmbientWithDiffuse = true
        guard let zombieScene = SCNScene(named: fileName) else { return }
        let zombieNode = zombieScene.rootNode.childNode(withName: childNode, recursively: false)!
        zombieNode.geometry?.materials = [test]
        zombieNode.position = SCNVector3Make(randomPosition(lowerBound: -7, upperBound: 7), -5, -11)
        
        let walkAction = SCNAction.move(to: SCNVector3(0, -5, 0), duration: TimeInterval(randomNumber(lowerBound: 10, upperBound: 15)))
        let billBoardConstraint = SCNBillboardConstraint()
        billBoardConstraint.freeAxes = [.Y]
        zombieNode.constraints = [billBoardConstraint]
        zombieNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: zombieNode, options: nil))
        zombieNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        zombieNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        zombieNode.runAction(walkAction)
        //Check for zombieNode.geometry if exists add materials`
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(spawnSeconds)) {
            self.sceneView.scene.rootNode.addChildNode(zombieNode)
        }
    }
    
    func gunSpawn() {
        guard let gunScene = SCNScene(named: "Glock.scnassets/Glock19.scn") else { return }
        let gunNode = gunScene.rootNode.childNode(withName: "Glock19", recursively: false)!
        gunNode.position = SCNVector3Make(0, -0.1, -0.2)
        self.sceneView.pointOfView?.addChildNode(gunNode)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.contactTestBitMask == BitMaskCategory.target.rawValue {
            if zombieHealth > 0 {
                zombieHealth -= 1
                self.Target = nodeA
            } else if zombieHealth == 0 {
                nodeB.removeFromParentNode()
                zombieHealth = 5
            }
        } else if nodeB.physicsBody?.contactTestBitMask == BitMaskCategory.target.rawValue {
            if zombieHealth > 0 {
                zombieHealth -= 1
                self.Target = nodeB
            } else if zombieHealth == 0 {
                nodeA.removeFromParentNode()
                zombieHealth = 5
            }
            
            let smoke = SCNParticleSystem(named: "Smoke.scnassets/Smoke.scnp", inDirectory: nil)
            smoke?.loops = false
            smoke?.particleLifeSpan = 4
            smoke?.emitterShape = Target?.geometry
            let smokeNode = SCNNode()
            smokeNode.addParticleSystem(smoke!)
            smokeNode.position = contact.contactPoint
            self.sceneView.scene.rootNode.addChildNode(smokeNode)
            Target?.removeFromParentNode()
        }
    }
    
    func playZombieSound() {
        guard let path = Bundle.main.path(forResource: "Zombie.wav", ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.play()
        } catch {
            print("couldnt play audio")
        }
    }
}

func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}
