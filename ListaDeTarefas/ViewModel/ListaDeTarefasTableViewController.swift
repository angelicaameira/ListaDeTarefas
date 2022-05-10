//
//  ListaDeTarefasTableViewController.swift
//  ListaDeTarefas
//
//  Created by Angélica Andrade de Meira on 26/04/22.
//

import UIKit
import CoreData

class ListaDeTarefasTableViewController: UITableViewController {
    
    var listaSelecionada: NSManagedObject?
    var tarefaSelecionada: NSManagedObject?
    var contexto: NSManagedObjectContext?
    var listaDeTarefas: [NSManagedObject] = []
    
    // MARK: - View code
    
    private lazy var botaoAdicionarTarefa: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Nova Tarefa"
        view.target = self
        view.action = #selector(vaiParaAdicionarTarefa)
        return view
    }()
    
    @objc func vaiParaAdicionarTarefa() {
        let viewDeDestino = AdicionaTarefaViewController()
        viewDeDestino.listaSelecionada = self.listaSelecionada
        self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = (listaSelecionada?.value(forKey: "descricao") as? String)
        self.navigationItem.rightBarButtonItems = [botaoAdicionarTarefa]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "celulaMinhasTarefas")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        contexto = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recuperaTarefas()
    }
    
    func recuperaTarefas() {
        guard let lista = listaSelecionada else { return }
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Tarefa")
        let ordenacao = NSSortDescriptor(key: "descricao", ascending: true)
        
        requisicao.predicate = NSPredicate(format: "lista = %@", lista)
        requisicao.sortDescriptors = [ordenacao]
        
        do {
            guard let contexto = contexto else { return }
                let tarefasRecuperadas = try contexto.fetch(requisicao)
                guard let tarefasRecuperadas = tarefasRecuperadas as? [NSManagedObject]
                else { return }
                self.listaDeTarefas = tarefasRecuperadas
                tableView.reloadData()
        } catch let erro {
            print("Erro ao carregar tarefas:" + erro.localizedDescription)
        }
    }
    
    func removeTarefa(indexPath: IndexPath){
        let tarefa = self.listaDeTarefas[indexPath.row]
        
        if let contexto = self.contexto{
            contexto.delete(tarefa)
            self.listaDeTarefas.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            do {
                try contexto.save()
            } catch let erro  {
                print("Erro ao remover tarefa:" + erro.localizedDescription)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaDeTarefas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaMinhasTarefas", for: indexPath)
        let dadosTarefa = self.listaDeTarefas[indexPath.row]
        
        celula.textLabel?.text = dadosTarefa.value(forKey: "descricao") as? String
        celula.accessoryType = .disclosureIndicator
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.cellForRow(at: indexPath)?.accessoryType == .disclosureIndicator {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .disclosureIndicator
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acoes = [
            UIContextualAction(style: .destructive, title: "Apagar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self else { return }
                self.removeTarefa(indexPath: indexPath)
                tableView.reloadData()
            }),
            UIContextualAction(style: .normal, title: "Editar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self else { return }
                let indice = indexPath.row
                self.tarefaSelecionada = self.listaDeTarefas[indice]
                let viewDeDestino = AdicionaTarefaViewController()
                viewDeDestino.tarefaSelecionada = self.tarefaSelecionada
                viewDeDestino.listaSelecionada = self.listaSelecionada
                self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
            })
        ]
        return UISwipeActionsConfiguration(actions: acoes)
    }
}
