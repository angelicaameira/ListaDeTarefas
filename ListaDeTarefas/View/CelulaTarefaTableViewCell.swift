//
//  CelulaTarefaTableViewCell.swift
//  ListaDeTarefas
//
//  Created by Angélica Andrade de Meira on 09/05/22.
//

import UIKit

class CelulaTarefaTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "celulaTarefa")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
