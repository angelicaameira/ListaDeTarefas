//
//  TelaInicialTableViewController.swift
//  ListaDeTarefas
//
//  Created by Angélica Andrade de Meira on 25/04/22.
//

import UIKit
import CoreData

class TelaInicialTableViewController: UITableViewController, TelaInicialTableViewControllerDelegate {
    
    var contexto: NSManagedObjectContext!
    var listaDeListas: [NSManagedObject] = []
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
        let viewDeDestino = AdicionaListaViewController()
        viewDeDestino.delegate = self
        self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Minhas listas"
        self.navigationItem.rightBarButtonItems = [botaoAdicionarLista]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(CelulaListaTableViewCell.self, forCellReuseIdentifier: "celulaLista")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        contexto = appDelegate.persistentContainer.viewContext
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recuperaListas()
        contaQuantidadeDeTarefasAFazer()
    }
    
    func recuperaListas() {
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Lista")
        let ordenacao = NSSortDescriptor(key: "descricao", ascending: true)
        requisicao.sortDescriptors = [ordenacao]
        
        do {
            
            if let contexto = contexto {
                let listasRecuperadas = try contexto.fetch(requisicao)
                self.listaDeListas = listasRecuperadas as! [NSManagedObject]
                tableView.reloadData()
            }else{
                return
            }
        } catch let erro {
            print("Erro ao carregar listas:" + erro.localizedDescription)
        }
    }
    
    func contaQuantidadeDeTarefasAFazer() {
        var contador = 0
        for lista in listaDeListas {
            let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Tarefa")
            requisicao.predicate = NSPredicate(format: "lista = %@ and checkbox = false", lista)
            
            do {
                if let contexto = contexto {
                    contador = try contexto.count(for: requisicao)
                    lista.setValue(contador, forKey: "quantidade")
                    try contexto.save()
                    tableView.reloadData()
                } else {
                    return
                }
            } catch let erro {
                print("Erro ao salvar listas:" + erro.localizedDescription)
            }
        }
    }
    
    func removeLista(indexPath: IndexPath){
        let lista = self.listaDeListas[indexPath.row]
        
        if let contexto = self.contexto{
            contexto.delete(lista)
            self.listaDeListas.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            do {
                try contexto.save()
            } catch let erro  {
                print("Erro ao remover lista:" + erro.localizedDescription)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaDeListas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let celula = tableView.dequeueReusableCell(withIdentifier: "celulaLista", for: indexPath) as? CelulaListaTableViewCell
        else { return UITableViewCell() }
        let dadosLista = self.listaDeListas[indexPath.row]
        
        celula.accessoryType = .disclosureIndicator
        celula.textLabel?.text = (dadosLista.value(forKey: "descricao") as? String)

        if let valor = dadosLista.value(forKey: "quantidade") as? Int {
            celula.detailTextLabel?.text = "\(valor)"
        }
      
        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.listaSelecionada = self.listaDeListas[indexPath.row]
        let viewDestino = ListaDeTarefasTableViewController()
        viewDestino.listaSelecionada = self.listaSelecionada
        self.navigationController?.pushViewController(viewDestino, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acoes = [
            UIContextualAction(style: .destructive, title: "Apagar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self else { return }
                self.removeLista(indexPath: indexPath)
                tableView.reloadData()
            }),
            UIContextualAction(style: .normal, title: "Editar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self else { return }
                let indice = indexPath.row
                self.listaSelecionada = self.listaDeListas[indice]
                let viewDeDestino = AdicionaListaViewController()
                viewDeDestino.listaSelecionada = self.listaSelecionada
                viewDeDestino.delegate = self
                self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
            })
        ]
        return UISwipeActionsConfiguration(actions: acoes)
    }
}

protocol TelaInicialTableViewControllerDelegate: AnyObject {
    func recuperaListas()
}
