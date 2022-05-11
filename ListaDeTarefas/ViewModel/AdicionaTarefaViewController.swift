//
//  AdicionaTarefaViewController.swift
//  ListaDeTarefas
//
//  Created by Angélica Andrade de Meira on 26/04/22.
//

import UIKit
import CoreData

class AdicionaTarefaViewController: UIViewController, UITextFieldDelegate {
    
    var tarefaSelecionada: NSManagedObject?
    var contexto: NSManagedObjectContext!
    var listaSelecionada: NSManagedObject?
    
    // MARK: - View code
    
    private lazy var botaoOk: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Ok"
        view.action = #selector(ok)
        return view
    }()
    
    private lazy var botaoCancelar: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.title = "Cancelar"
        view.action = #selector(cancelar)
        return view
    }()
    
    private lazy var campoDescricao: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.borderStyle = .roundedRect
        view.placeholder = "Insira o título da tarefa"
        view.returnKeyType = .done
        view.becomeFirstResponder()
        return view
    }()
    
    private lazy var campoDetalhes: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.borderStyle = .roundedRect
        view.placeholder = "Insira os detalhes da tarefa"
        view.returnKeyType = .done
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItems = [botaoOk]
        self.navigationItem.leftBarButtonItems = [botaoCancelar]
        self.view.addSubview(campoDescricao)
        self.view.addSubview(campoDetalhes)
        
        if tarefaSelecionada != nil {
            self.title = "Editar tarefa"
        } else {
            self.title = "Nova tarefa"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        campoDescricao.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        campoDescricao.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        campoDescricao.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        campoDetalhes.topAnchor.constraint(equalTo: self.campoDescricao.bottomAnchor, constant: 10).isActive = true
        campoDetalhes.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        campoDetalhes.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        
        campoDescricao.delegate = self
        campoDetalhes.delegate = self
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        contexto = appDelegate.persistentContainer.viewContext
    }
    
    @objc func ok() {
        if tarefaSelecionada == nil{
            salvarNovaTarefa()
        } else {
            atualizarTarefa()
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelar() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func salvarNovaTarefa(){
        if let lista = listaSelecionada {
            let novaTarefa = NSEntityDescription.insertNewObject(forEntityName: "Tarefa", into: contexto)
            novaTarefa.setValue(self.campoDescricao.text, forKey: "descricao")
            novaTarefa.setValue(self.campoDetalhes.text, forKey: "detalhes")
            novaTarefa.setValue(lista, forKey: "lista")
            
            do {
                try contexto.save()
            } catch let erro {
                print("Erro ao salvar tarefa:" + erro.localizedDescription)
            }
        }
    }
    
    func atualizarTarefa() {
        guard let tarefa = self.tarefaSelecionada
        else { return }
        tarefa.setValue(self.campoDescricao.text, forKey: "descricao")
        tarefa.setValue(self.campoDetalhes.text, forKey: "detalhes")
        
        do {
            try contexto.save()
        } catch let erro {
            print("Erro ao atualizar tarefa:" + erro.localizedDescription)
        }
    }
    
    func setup() {
        guard let tarefa = self.tarefaSelecionada
        else { return }
        campoDescricao.text = tarefa.value(forKey: "descricao") as? String
        campoDetalhes.text = tarefa.value(forKey: "detalhes") as? String
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ok()
        return true
    }
}
