//
//  Spinner.swift
//  ProSpinner
//
//  Created by AlexP on 31.5.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Foundation
import SpriteKit

class Spinner : NSObject,NSCoding
{
    var id           : Int?
    var imageUrlLink : String?
    var texture      : SKTexture?
    var redNeeded    : Int?
    var blueNeeded   : Int?
    var greenNeeded  : Int?
    var mainSpinner  : Bool? = false
    var unlocked     :Bool? = false
    
    init(id: Int?, imageUrlLink: String?, texture: SKTexture?, redNeeded: Int?, blueNeeded: Int?, greenNeeded: Int?,mainSpinner: Bool?,unlocked: Bool?)
    {
        self.id     = id
        self.imageUrlLink   = imageUrlLink
        self.texture  = texture
        self.redNeeded   = redNeeded
        self.blueNeeded  = blueNeeded
        self.greenNeeded   = greenNeeded
        self.mainSpinner  = mainSpinner
        self.unlocked = unlocked
    }
    
    init(id: Int,unlocked: Bool = false, redNeeded: Int, blueNeeded: Int, greenNeeded: Int)
    {
        self.id             = id
        self.imageUrlLink   = "gs://prospinner-a4255.appspot.com/SpinnersTextures/\(id)/spinner.png"
        self.texture        = SKTexture(imageNamed: "\(id)")
        self.redNeeded      = redNeeded
        self.blueNeeded     = blueNeeded
        self.greenNeeded    = greenNeeded
        self.mainSpinner    = false
        self.unlocked       = unlocked
    }
    
    
    required init?(coder decoder: NSCoder)
    {
        self.id             = decoder.decodeObject(forKey: "id"          ) as? Int  ?? 0
        self.imageUrlLink   = decoder.decodeObject(forKey: "link"        ) as? String  ?? ""
        self.texture        = decoder.decodeObject(forKey: "texture"     ) as? SKTexture  ?? nil
        self.redNeeded      = decoder.decodeObject(forKey: "red"         ) as? Int  ?? 0
        self.blueNeeded     = decoder.decodeObject(forKey: "blue"        ) as? Int ?? 0
        self.greenNeeded    = decoder.decodeObject(forKey: "green"       ) as? Int ?? 0
        self.mainSpinner    = decoder.decodeObject(forKey: "mainSpinner" ) as? Bool ?? false
        self.unlocked       = decoder.decodeObject(forKey: "unlocked"    ) as? Bool ?? false
    }
    
    func encode(with coder: NSCoder) {
        
        coder.encode(self.id            , forKey: "id"         )
        coder.encode(self.imageUrlLink  , forKey: "link"       )
        coder.encode(self.texture       , forKey: "texture"    )
        coder.encode(self.redNeeded     , forKey: "red"        )
        coder.encode(self.blueNeeded    , forKey: "blue"       )
        coder.encode(self.greenNeeded   , forKey: "green"      )
        coder.encode(self.mainSpinner   , forKey: "mainSpinner")
        coder.encode(self.unlocked      , forKey: "unlocked"   )
    }
}
