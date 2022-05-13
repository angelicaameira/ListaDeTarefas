//
//  TelaInicialTableViewController.swift
//  ListaDeTarefas
//
//  Created by Angélica Andrade de Meira on 25/04/22.
//

import UIKit
import CoreData

class TelaInicialTableViewController: UITableViewController {
    
    var contexto: NSManagedObjectContext?
    var listaDeListas: [NSManagedObject]? = []
    var listaSelecionada: NSManagedObject?
    
    // MARK: - View code
    
    private lazy var botaoAdicionarLista: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Nova Lista"
        view.target = self
        view.action = #selector(vaiParaAdicionarLista)
        return view
    }()
    
    @objc func vaiParaAdicionarLista() {
        self.present(UINavigationController(rootViewController: AdicionaListaViewController()), animated: true)
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Minhas listas"
        self.navigationItem.rightBarButtonItems = [botaoAdicionarLista]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "celulaMinhasListas")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }
        contexto = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recuperaListas()
    }
    
    func recuperaListas() {
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Lista")
        let ordenacao = NSSortDescriptor(key: "descricao", ascending: true)
        requisicao.sortDescriptors = [ordenacao]
        
        do {
            guard let contexto = contexto
            else { return }
            let listasRecuperadas = try contexto.fetch(requisicao)
            self.listaDeListas = listasRecuperadas as? [NSManagedObject]
            tableView.reloadData()
            
        } catch let erro {
            print("Erro ao carregar listas:" + erro.localizedDescription)
        }
    }
    
    func removeLista(indexPath: IndexPath) {
        guard let lista = self.listaDeListas?[indexPath.row],
              let contexto = self.contexto
        else { return }
        contexto.delete(lista)
        self.listaDeListas?.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        do {
            try contexto.save()
        } catch let erro {
            print("Erro ao remover lista:" + erro.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaDeListas?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaMinhasListas", for: indexPath)
        let dadosLista = self.listaDeListas?[indexPath.row]
        
        celula.accessoryType = .disclosureIndicator
        celula.textLabel?.text = dadosLista?.value(forKey: "descricao") as? String
        
        let checkbox = dadosLista.value(forKey: "checkbox") as? Bool
        celula.accessoryType = .disclosureIndicator
      
        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.listaSelecionada = self.listaDeListas?[indexPath.row]
        let viewDestino = ListaDeTarefasTableViewController()
        viewDestino.listaSelecionada = self.listaSelecionada
        self.navigationController?.pushViewController(viewDestino, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acoes = [
            UIContextualAction(style: .destructive, title: "Apagar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self
                else { return }
                self.removeLista(indexPath: indexPath)
                tableView.reloadData()
            }),
            UIContextualAction(style: .normal, title: "Editar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self
                else { return }
                let indice = indexPath.row
                self.listaSelecionada = self.listaDeListas?[indice]
                let viewDeDestino = AdicionaListaViewController()
                viewDeDestino.listaSelecionada = self.listaSelecionada
                self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
            })
        ]
        return UISwipeActionsConfiguration(actions: acoes)
    }
}

protocol TelaInicialTableViewControllerDelegate: AnyObject {
    func chamaRecuperaListas()
}
