//
//  ListaDeTarefasTableViewController.swift
//  ListaDeTarefas
//
//  Created by Angélica Andrade de Meira on 26/04/22.
//

import UIKit
import CoreData

class ListaDeTarefasTableViewController: UITableViewController, ListaDeTarefasTableViewControllerDelegate {
    
    var listaSelecionada: NSManagedObject?
    var tarefaSelecionada: NSManagedObject?
    var contexto: NSManagedObjectContext!
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
        viewDeDestino.delegate = self
        self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = listaSelecionada?.value(forKey: "descricao") as? String
        self.navigationItem.rightBarButtonItems = [botaoAdicionarTarefa]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(CelulaTarefaTableViewCell.self, forCellReuseIdentifier: "celulaTarefa")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }
        contexto = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recuperaTarefas()
    }
    
    func recuperaTarefas() {
        guard let lista = listaSelecionada
        else { return }
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Tarefa")
        let ordenacao = NSSortDescriptor(key: "descricao", ascending: true)
        
        requisicao.predicate = NSPredicate(format: "lista = %@", lista)
        requisicao.sortDescriptors = [ordenacao]
        
        do {
            
            guard let contexto = contexto
            else { return }
            
            let tarefasRecuperadas = try contexto.fetch(requisicao)
            self.listaDeTarefas = tarefasRecuperadas as! [NSManagedObject]
            
            tableView.reloadData()
            
        } catch let erro {
            print("Erro ao carregar tarefas:" + erro.localizedDescription)
        }
    }
    
    func removeTarefa(indexPath: IndexPath) {
        let tarefa = self.listaDeTarefas[indexPath.row]
        
        guard let contexto = self.contexto
        else { return }
        
        contexto.delete(tarefa)
        self.listaDeTarefas.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        do {
            try contexto.save()
        } catch let erro {
            print("Erro ao remover tarefa:" + erro.localizedDescription)
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
        guard let celula = tableView.dequeueReusableCell(withIdentifier: "celulaTarefa", for: indexPath) as? CelulaTarefaTableViewCell
        else { return UITableViewCell() }
        
        let dadosTarefa = self.listaDeTarefas[indexPath.row]
        let descricao = dadosTarefa.value(forKey: "descricao") as? String
        let detalhes = dadosTarefa.value(forKey: "detalhes") as? String
        
        celula.textLabel?.text = descricao
        celula.textLabel?.text = dadosTarefa.value(forKey: "descricao") as? String
        celula.detailTextLabel?.text = detalhes
        celula.detailTextLabel?.numberOfLines = 0
        
        guard let checkbox = dadosTarefa.value(forKey: "checkbox") as? Bool
        else { return celula }
        
        celula.accessoryType = checkbox ? .checkmark : .none
        
        return celula
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.tarefaSelecionada = self.listaDeTarefas[indexPath.row]
        
        guard let checkboxTarefa = self.tarefaSelecionada?.value(forKey: "checkbox") as? Bool
        else { return }
        
        if checkboxTarefa == false {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            tarefaSelecionada?.setValue(true, forKey: "checkbox")
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            tarefaSelecionada?.setValue(false, forKey: "checkbox")
        }
        
        do {
            try contexto.save()
        } catch let erro  {
            print("Erro ao atualizar tarefa:" + erro.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acoes = [
            UIContextualAction(style: .destructive, title: "Apagar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self
                else { return }
                self.removeTarefa(indexPath: indexPath)
                tableView.reloadData()
            }),
            UIContextualAction(style: .normal, title: "Editar", handler: { [weak self] (contextualAction, view, _) in
                guard let self = self
                else { return }
                let indice = indexPath.row
                self.tarefaSelecionada = self.listaDeTarefas[indice]
                let viewDeDestino = AdicionaTarefaViewController()
                viewDeDestino.tarefaSelecionada = self.tarefaSelecionada
                viewDeDestino.listaSelecionada = self.listaSelecionada
                viewDeDestino.delegate = self
                self.present(UINavigationController(rootViewController: viewDeDestino), animated: true)
            })
        ]
        return UISwipeActionsConfiguration(actions: acoes)
    }
}

protocol ListaDeTarefasTableViewControllerDelegate: AnyObject {
    func recuperaTarefas()
}
