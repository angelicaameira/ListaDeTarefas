//
//  AdicionaTarefaViewController.swift
//  ListaDeTarefas
//
//  Created by Angélica Andrade de Meira on 26/04/22.
//

import UIKit
import CoreData

class AdicionaTarefaViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: ListaDeTarefasTableViewControllerDelegate?
    var tarefaSelecionada: NSManagedObject?
    var contexto: NSManagedObjectContext!
    var listaSelecionada: NSManagedObject?
    var alertAdicionar = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao adicionar uma nova tarefa", preferredStyle: .alert)
    var alertEditar = UIAlertController(title: "Atenção!", message: "Um erro ocorreu ao editar a tarefa", preferredStyle: .alert)
    
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
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }
        contexto = appDelegate.persistentContainer.viewContext
    }
    
    @objc func ok() {
        if tarefaSelecionada == nil{
            salvarNovaTarefa()
        } else {
            atualizarTarefa()
        }
        self.navigationController?.dismiss(animated: true) { [weak self]
            in
            self?.delegate?.recuperaTarefas()
        }
    }
    
    @objc func cancelar() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func salvarNovaTarefa() {
        guard let lista = listaSelecionada
        else { return }
        let novaTarefa = NSEntityDescription.insertNewObject(forEntityName: "Tarefa", into: contexto)
        novaTarefa.setValue(self.campoDescricao.text, forKey: "descricao")
        novaTarefa.setValue(self.campoDetalhes.text, forKey: "detalhes")
        novaTarefa.setValue(false, forKey: "checkbox")
        novaTarefa.setValue(lista, forKey: "lista")
        
        do {
            try contexto.save()
        } catch let erro {
                self.alertAdicionar.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "tente novamente"), style: .default, handler: nil))
                print("Erro ao salvar tarefa:" + erro.localizedDescription)
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
                self.alertEditar.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "tente novamente"), style: .default, handler: nil))
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
