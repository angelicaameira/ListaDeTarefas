//
//  CelulaListaTableViewCell.swift
//  ListaDeTarefas
//
//  Created by Angélica Andrade de Meira on 04/05/22.
//

import UIKit

class CelulaListaTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "celulaLista")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
