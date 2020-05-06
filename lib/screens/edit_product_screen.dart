import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const nameRoute = '/edit-product-screen';

  @override
  _EditProductScreen createState() => _EditProductScreen();
}

class _EditProductScreen extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlcontroller = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _edittedProduct = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var isLoading = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        final product =
            Provider.of<Products>(context, listen: false).findById(productId);
        _edittedProduct = product;
        _initValues = {
          'title': _edittedProduct.title,
          'description': _edittedProduct.description,
          'price': _edittedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlcontroller.text = _edittedProduct.imageUrl;
      }
    }
    _isInit = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlcontroller.dispose();
    _imageUrlFocusNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final valid = _form.currentState.validate();
    if (!valid) return;
    _form.currentState.save();
    setState(() {
      isLoading = true;
    });
    if (_edittedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_edittedProduct.id, _edittedProduct);
      Navigator.of(context).pop();
      setState(() {
        isLoading = false;
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_edittedProduct);
      } catch (error) {
        showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error Occurred'),
            content: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Added Product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: () => _saveForm())
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _edittedProduct = Product(
                          id: _edittedProduct.id,
                          isFavorite: _edittedProduct.isFavorite,
                          title: value,
                          description: _edittedProduct.description,
                          price: _edittedProduct.price,
                          imageUrl: _edittedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'PLease enter a price.';
                        if (double.tryParse(value) == null)
                          return 'Please enter a valid number.';
                        if (double.parse(value) <= 0)
                          return 'Please enter a number greater then 0.';
                        return null;
                      },
                      onSaved: (value) {
                        _edittedProduct = Product(
                          id: _edittedProduct.id,
                          isFavorite: _edittedProduct.isFavorite,
                          title: _edittedProduct.title,
                          description: _edittedProduct.description,
                          price: double.parse(value),
                          imageUrl: _edittedProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a description.';
                        if (value.length < 10)
                          return 'Should be at least 10 chr long';
                        return null;
                      },
                      onSaved: (value) {
                        _edittedProduct = Product(
                          id: _edittedProduct.id,
                          isFavorite: _edittedProduct.isFavorite,
                          title: _edittedProduct.title,
                          description: value,
                          price: _edittedProduct.price,
                          imageUrl: _edittedProduct.imageUrl,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: Container(
                            child: _imageUrlcontroller.text.isEmpty
                                ? Text('Enter URL')
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlcontroller.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            initialValue: null,
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlcontroller,
                            focusNode: _imageUrlFocusNode,
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter an image URL.';
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https'))
                                return 'Please enter a valid URL.';
                             /* if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpeg') &&
                                  !value.endsWith('jpg'))
                                return 'Please enter a valid image URL';*/
                              return null;
                            },
                            onSaved: (value) {
                              _edittedProduct = Product(
                                id: _edittedProduct.id,
                                isFavorite: _edittedProduct.isFavorite,
                                title: _edittedProduct.title,
                                description: _edittedProduct.description,
                                price: _edittedProduct.price,
                                imageUrl: value,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    RaisedButton(onPressed: () => _saveForm())
                  ],
                ),
              ),
            ),
    );
  }
}
