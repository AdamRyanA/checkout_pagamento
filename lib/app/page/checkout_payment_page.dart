import 'dart:convert';
import 'dart:io';
import 'package:checkout_pagamento/app/page/pix.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:credit_card_type_detector/models.dart';
import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:path_provider/path_provider.dart';
import '../util/color.dart';
import '../util/paths.dart';
import '../widget/clipboard.dart';
import 'card_page.dart';

class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final CreditCardValidator _ccValidator = CreditCardValidator();
  TextEditingController controllerNumber = TextEditingController();
  TextEditingController controllerData = TextEditingController();
  TextEditingController controllerCVV = TextEditingController();
  var maskNumber = MaskTextInputFormatter(mask: '#### #### #### ####');
  var maskData = MaskTextInputFormatter(mask: '##/##');
  var maskCVV = MaskTextInputFormatter(mask: '###');
  String tipoCard = "";
  String image = "";
  String formaPagamento = "";
  String pixCode =
      "SHDFLUBISUHFGUYNHhYBUYD54634GDHBSFJYHFSXghbfdSHDFLUBISUHFGUYNHhYBUYD54634GDHBSFJYHFSXghbfd";
  List listaCard = [];
  List<String> stringList = [];
  List<Map<String, dynamic>> mapList = [];
  Map<String, dynamic> item = {};
  var f = NumberFormat('###.00', 'pt_BR');
  final double _totalDouble = 80.00;
  DateTime? _selected;
  late Widget icon = Container(
    height: 1,
    width: 1,
    color: Colors.transparent,
  );

  Future<File> getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path.toString()}/teste.json");
  }

  _addList() async {
    stringList.clear();

    //Add stringList
    stringList.add("pix");
    stringList.add("add");
    if (listaCard.isNotEmpty) {
      for (var i = 0; i < listaCard.length; i++) {
        setState(() {
          stringList.add("card$i");
        });
      }
    } else {
      if (kDebugMode) {
        print("ERRO listCard null");
      }
    }
    //Add mapList
    setState(() {
      mapList.clear();
      for (var element in stringList) {
        mapList.add({"nome": element, "selected": false});
      }
    });
  }

  _click(String nome) {
    for (var element in mapList) {
      if (element['selected'] == true) {
        element['selected'] = false;
      }
      if (nome == element['nome']) {
        if (element["selected"] == false) {
          element["selected"] = true;
        }
        setState(() {
          formaPagamento = "${element['nome']}";
        });
      }
    }
    setState(() {
      _boolElement;
    });
  }

  bool _boolElement(String nome) {
    bool selected = false;
    for (var element in mapList) {
      if (nome == element['nome']) {
        if (element["selected"] == false) {
          selected = false;
        } else if (element["selected"] == true) {
          selected = true;
        }
      }
    }
    return selected;
  }

  bool _boolButton() {
    bool selected = false;
    for (var element in mapList) {
      if (element['selected'] == true) {
        selected = true;
      }
    }
    return selected;
  }

  _onBottomNav(double altura) {
    if (formaPagamento == "pix") {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext context) {
          return PixPage(pixCode: pixCode, copy: _copy, altura: altura);
        },
      );
    } else if (formaPagamento != "add") {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => CardPage(card: item)));
      Fluttertoast.showToast(
          msg:
              "Forma de Pagamento: ${item['tipoCard'].toString().toUpperCase()}",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white);
    }
  }

  _copy() async {
    ClipboardHelper.copy(pixCode);
    Fluttertoast.showToast(
        msg: "Pix Copiado!!!",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white);
  }

  _validate() async {
    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) {
        print("Invalid Card");
      }
    } else {
      String numberFormated = controllerNumber.text.replaceAll(" ", "");
      String dataFormated = controllerData.text.replaceAll("/", "");
      String cvvFormated = controllerCVV.text;
      _salvarCartao(numberFormated, dataFormated, cvvFormated);
      _clear();
    }
  }

  _typeCard(String number) {
    //5502 7200 6779 1032 Mastercard
    //3747 7200 6779 1032 Amex
    //6504 8500 1234 5678 Elo
    //4647 7200 6779 1032 Visa
    List<CreditCardType> types = detectCCType(number);
    double imageSize = 50.0;

    if (types.contains(CreditCardType.visa())) {
      icon = Image.asset(
        ImagePath.visa,
        width: imageSize,
      );
      setState(() {
        image = ImagePath.visa;
        tipoCard = "visa";
      });
    } else if (types.contains(CreditCardType.mastercard())) {
      icon = Image.asset(
        ImagePath.mastercard,
        width: imageSize,
      );
      setState(() {
        image = ImagePath.mastercard;
        tipoCard = "mastercard";
      });
    } else if (types.contains(CreditCardType.elo())) {
      icon = Image.asset(
        ImagePath.elo,
        width: imageSize,
      );
      setState(() {
        image = ImagePath.elo;
        tipoCard = 'elo';
      });
    } else if (types.contains(CreditCardType.americanExpress())) {
      icon = Image.asset(
        ImagePath.american,
        width: imageSize,
      );
      setState(() {
        image = ImagePath.american;
        tipoCard = 'american';
      });
    } else if (types.contains(CreditCardType.hipercard())) {
      icon = Image.asset(
        ImagePath.hipercard,
        width: imageSize,
      );
      setState(() {
        image = ImagePath.hipercard;
        tipoCard = 'hipercard';
      });
    } else if (types.contains(CreditCardType.dinersClub())) {
      icon = Image.asset(
        ImagePath.diners,
        width: imageSize,
      );
      setState(() {
        image = ImagePath.diners;
        tipoCard = 'diners';
      });
    } else {
      icon = Icon(
        Icons.credit_card_off_outlined,
        size: imageSize,
        color: primaryColorDark,
      );
      if (kDebugMode) {
        print("Sem bandeira");
      }
    }
  }

  _clear() {
    controllerNumber.clear();
    controllerData.clear();
    controllerCVV.clear();
    icon = Container(
      height: 1,
      width: 1,
      color: Colors.transparent,
    );
  }

  _salvarCartao(String number, String data, String cvv) {
    Map<String, dynamic> cartao = {};
    cartao['numberCard'] = number;
    cartao['tipoCard'] = tipoCard;
    cartao['image'] = image;
    setState(() {
      listaCard.add(cartao);
    });
    _salvarArquivo();
    Navigator.pop(context);
  }

  _salvarArquivo() async {
    var arquivo = await getFile();
    String dados = json.encode(listaCard);
    arquivo.writeAsString(dados);
    Fluttertoast.showToast(
        msg: "Cartão de Crédito Adicionado",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white);
  }

  _removeArquivo(int index) async {
    if (!context.mounted) return;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Atenção"),
            content: const Text("Deseja realmente deletar seu cartão?"),
            contentPadding: const EdgeInsets.all(16),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          listaCard.removeAt(index);
                        });
                        Navigator.pop(context);
                        _salvarArquivo();
                      },
                      child: const Text("Confirmar")),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar")),
                ],
              )
            ],
          );
        });
  }

  lerArquivo() async {
    final arquivo = await getFile();
    arquivo.readAsString().then((dados) {
      setState(() {
        listaCard = json.decode(dados);
        _addList();
      });
    });
  }

  _onPressed(
    BuildContext context,
    String? locale,
  ) async {
    var date = DateTime.now();
    final localeObj = locale != null ? Locale(locale) : null;
    showMonthPicker(
      context: context,
      initialDate: _selected ?? date,
      firstDate: DateTime(date.year),
      lastDate: DateTime(date.year + 15),
      locale: localeObj,
      headerColor: primaryColorDark,
      headerTextColor: blankColor,
      selectedMonthBackgroundColor: primaryColor,
      selectedMonthTextColor: blankColor,
      unselectedMonthTextColor: primaryColorDark,
      backgroundColor: blankColor,
      confirmWidget: Text('OK',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: primaryColorDark)),
      cancelWidget: Text('Cancelar',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: primaryColorDark)),
      yearFirst: true,
    ).then((DateTime? date) {
      if (date != null) {
        setState(() {
          _selected = date;
          String data =
              maskData.maskText(DateFormat('MM/yy').format(_selected!));
          controllerData.text = data;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    lerArquivo();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      var altura = constraint.maxHeight;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text("Pagamento".toUpperCase()),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Row(
                        children: [
                          Text(
                            "Subtotal",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 4, bottom: 4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "10 km (R\$ 2,00/km)",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                "R\$ 50,00",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Pedágio",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )),
                              Text(
                                "R\$ 0,00",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "Carga e Descarga",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )),
                              Text(
                                "R\$ 10,00",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Row(
                        children: [
                          Text(
                            "Adicional",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 4, bottom: 4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text("Ajuda motorista",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ))),
                              Text(
                                "R\$ 10,00",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text("Ajudante",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ))),
                              Text(
                                "R\$ 10,00",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Total",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColorDark),
                            ),
                          ),
                          Text(
                            "R\$ 80,00",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColorDark),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    Text(
                      "Métodos de pagamento",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                backgroundColor: _boolElement("pix")
                                    ? primaryColorLight
                                    : null,
                                foregroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(
                                    color: _boolElement("pix")
                                        ? primaryColor
                                        : Colors.grey[400]!,
                                    width: 2)),
                            onPressed: () {
                              _click("pix");
                            },
                            child: SizedBox(
                                height: 100,
                                width: 110,
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  ImagePath.pix,
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                const Text(
                                                  "Pix",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.black),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Icon(
                                        _boolElement("pix")
                                            ? Icons.check_circle_outlined
                                            : Icons.circle_outlined,
                                        color: _boolElement("pix")
                                            ? primaryColor
                                            : Colors.grey[400]!,
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        SizedBox(
                            height: 116,
                            width: 158 * listaCard.length.toDouble(),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: listaCard.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (_, index) {
                                  Map<String, dynamic> card = listaCard[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          backgroundColor:
                                              _boolElement("card$index")
                                                  ? primaryColorLight
                                                  : null,
                                          foregroundColor: Colors.grey,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          side: BorderSide(
                                              color: _boolElement("card$index")
                                                  ? primaryColor
                                                  : Colors.grey[400]!,
                                              width: 2)),
                                      onPressed: () {
                                        _click("card$index");
                                        item = card;
                                      },
                                      onLongPress: () {
                                        _removeArquivo(index);
                                      },
                                      child: SizedBox(
                                        height: 100,
                                        width: 110,
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional.topEnd,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4, bottom: 4),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          "${card['image']}",
                                                          width: 50,
                                                          height: 50,
                                                        ),
                                                        Text(
                                                          "${card['tipoCard']}",
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                        Text(
                                                          "•••• ${card['numberCard'].substring(card['numberCard'].length - 4)}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .grey[600]),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Icon(
                                                _boolElement("card$index")
                                                    ? Icons
                                                        .check_circle_outlined
                                                    : Icons.circle_outlined,
                                                color:
                                                    _boolElement("card$index")
                                                        ? primaryColor
                                                        : Colors.grey[400],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                backgroundColor: _boolElement("add")
                                    ? primaryColorLight
                                    : null,
                                foregroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(
                                    color: _boolElement("add")
                                        ? primaryColor
                                        : Colors.grey[400]!,
                                    width: 2)),
                            onPressed: () async {
                              _click("add");
                              await showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20))),
                                  backgroundColor: blankColor,
                                  builder: (BuildContext context) {
                                    return Form(
                                        key: _formKey,
                                        child: SafeArea(
                                          child: Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 12,
                                                            horizontal: 6),
                                                    child: Text(
                                                      "Inserir dados do cartão",
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4,
                                                              bottom: 4),
                                                      child: TextFormField(
                                                        controller:
                                                            controllerNumber,
                                                        style: const TextStyle(
                                                            fontSize: 20),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          maskNumber
                                                        ],
                                                        decoration:
                                                            InputDecoration(
                                                                enabledBorder: OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color:
                                                                            primaryColorDark,
                                                                        width:
                                                                            1)),
                                                                hintText:
                                                                    "XXXX XXXX XXXX XXXX",
                                                                labelText:
                                                                    "Número",
                                                                labelStyle:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                hintStyle:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  color:
                                                                      primaryColorDark,
                                                                ),
                                                                suffixIcon: Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            4),
                                                                    child:
                                                                        icon),
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6))),
                                                        validator: (valor) {
                                                          String
                                                              numberFormated =
                                                              controllerNumber
                                                                  .text
                                                                  .replaceAll(
                                                                      " ", "");
                                                          var ccNumResults =
                                                              _ccValidator
                                                                  .validateCCNum(
                                                                      numberFormated);
                                                          if (ccNumResults
                                                              .isValid) {
                                                            return null;
                                                          } else {
                                                            return "Digite um número válido";
                                                          }
                                                        },
                                                        onChanged: (valor) {
                                                          if (valor.isEmpty) {
                                                            _clear();
                                                          } else {
                                                            _typeCard(valor);
                                                          }
                                                        },
                                                      )),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 4,
                                                                      bottom: 4,
                                                                      right: 4),
                                                              child:
                                                                  TextFormField(
                                                                readOnly: true,
                                                                onTap: () {
                                                                  _onPressed(
                                                                      context,
                                                                      'pt');
                                                                },
                                                                controller:
                                                                    controllerData,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                decoration:
                                                                    InputDecoration(
                                                                        enabledBorder: OutlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color:
                                                                                    primaryColorDark,
                                                                                width:
                                                                                    1)),
                                                                        hintText:
                                                                            "MM/AA",
                                                                        labelText:
                                                                            "Data de Validade",
                                                                        labelStyle: const TextStyle(
                                                                            fontSize:
                                                                                18),
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color:
                                                                              primaryColorDark,
                                                                        ),
                                                                        border: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(6))),
                                                                validator:
                                                                    (valor) {
                                                                  String
                                                                      dataFormated =
                                                                      controllerData
                                                                          .text;
                                                                  var expDateResults =
                                                                      _ccValidator
                                                                          .validateExpDate(
                                                                              dataFormated);
                                                                  if (expDateResults
                                                                      .isValid) {
                                                                    return null;
                                                                  } else {
                                                                    return "Digite a Data de validade";
                                                                  }
                                                                },
                                                              ))),
                                                      Expanded(
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 4,
                                                                      bottom: 4,
                                                                      left: 4),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    controllerCVV,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                inputFormatters: [
                                                                  maskCVV
                                                                ],
                                                                decoration:
                                                                    InputDecoration(
                                                                        enabledBorder: OutlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                                color:
                                                                                    primaryColorDark,
                                                                                width:
                                                                                    1)),
                                                                        hintText:
                                                                            "XXX",
                                                                        labelText:
                                                                            "CVV",
                                                                        labelStyle: const TextStyle(
                                                                            fontSize:
                                                                                18),
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          color:
                                                                              primaryColorDark,
                                                                        ),
                                                                        border: OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(6))),
                                                                validator:
                                                                    (valor) {
                                                                  String
                                                                      cvvFormated =
                                                                      controllerCVV
                                                                          .text;
                                                                  if (cvvFormated
                                                                          .length ==
                                                                      3) {
                                                                    return null;
                                                                  } else {
                                                                    return "Digite o CVV";
                                                                  }
                                                                },
                                                              ))),
                                                    ],
                                                  ),
                                                  Expanded(child: Container()),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              primaryColorDark,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        32),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          _validate();
                                                        },
                                                        child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      FittedBox(
                                                                    fit: BoxFit
                                                                        .scaleDown,
                                                                    child: Text(
                                                                      'Cadastrar cartão',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )),
                                                      )),
                                                ],
                                              )),
                                        ));
                                  });
                              lerArquivo();
                            },
                            child: SizedBox(
                              height: 100,
                              width: 110,
                              child: Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_card_outlined,
                                                size: 50,
                                                color: primaryColorDark,
                                              ),
                                              const Text(
                                                "adicionar",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                "cartão de crédito",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.grey[600]),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Icon(
                                      _boolElement("add")
                                          ? Icons.check_circle_outlined
                                          : Icons.circle_outlined,
                                      color: _boolElement("add")
                                          ? primaryColor
                                          : Colors.grey[400],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: altura * 0.12,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              shape: BoxShape.rectangle,
              color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "total",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formaPagamento == "pix"
                        ? "R\$ ${f.format(_totalDouble - _totalDouble * 0.1)}"
                        : "R\$ ${f.format(_totalDouble)}",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColorDark),
                  )
                ],
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _boolButton()
                      ? () {
                          _onBottomNav(altura);
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _boolButton() ? "pagamento" : "selecione o pagamento",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ))
            ],
          ),
        ),
      );
    });
  }
}
