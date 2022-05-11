//
//  AdicionaListaViewController.swift
//  ListaDeTarefas
//
//  Created by Angélica Andrade de Meira on 25/04/22.
//

import UIKit
import CoreData

class AdicionaListaViewController: UIViewController, UITextFieldDelegate, TelaInicialTableViewControllerDelegate, UINavigationControllerDelegate {
    func chamaRecuperaListas() {
        //        let telaInicial: TelaInicialTableViewController
        //        telaInicial.recuperaListas()
    }
    
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
        view.placeholder = "Insira o nome da lista"
        view.returnKeyType = .done
        view.becomeFirstResponder()
        return view
    }()
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItems = [botaoOk]
        self.navigationItem.leftBarButtonItems = [botaoCancelar]
        self.view.addSubview(campoDescricao)
        
        if listaSelecionada != nil {
            self.title = "Editar lista"
        } else {
            self.title = "Nova lista"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        campoDescricao.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
        campoDescricao.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        campoDescricao.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        campoDescricao.delegate = self
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        contexto = appDelegate.persistentContainer.viewContext
    }
    
    @objc func ok() {
        if listaSelecionada == nil {
            salvarNovaLista()
        } else {
            atualizarNomeDaLista()
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
        chamaRecuperaListas()
    }
    
    @objc func cancelar() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func salvarNovaLista() {
        let novaLista = NSEntityDescription.insertNewObject(forEntityName: "Lista", into: contexto)
        novaLista.setValue(self.campoDescricao.text, forKey: "descricao")
        
        do {
            try contexto.save()
        } catch let erro {
            print("Erro ao salvar lista:" + erro.localizedDescription)
        }
    }
    
    func atualizarNomeDaLista() {
        guard let lista = self.listaSelecionada
        else { return } 
        lista.setValue(self.campoDescricao.text, forKey: "descricao")
        
        do {
            try contexto.save()
        } catch let erro {
            print("Erro ao atualizar nome da lista:" + erro.localizedDescription)
        }
    }
    
    func setup() {
        guard let lista = self.listaSelecionada
        else { return }
        campoDescricao.text = lista.value(forKey: "descricao") as? String
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ok()
        return true
    }
}
