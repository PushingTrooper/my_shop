import 'package:flutter/material.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product_screen';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _product =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      final arguments = ModalRoute.of(context)?.settings.arguments;

      if (arguments != null) {
        final productId = arguments as String;

        final product =
            Provider.of<Products>(context, listen: false).findById(productId);
        _product = product;

        _initValues = {
          'title': product.title,
          'description': product.description,
          'price': product.price.toString(),
          'imageUrl': product.imageUrl
        };

        _imageUrlController.text = product.imageUrl;
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid =
        _form.currentState != null ? _form.currentState!.validate() : false;
    if (isValid) {
      _form.currentState?.save();

      setState(() {
        _isLoading = true;
      });

      if (_product.id.isNotEmpty) {
        Provider.of<Products>(context, listen: false)
            .updateProduct(_product.id, _product);

        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
        });
      } else {
        try {
          await Provider.of<Products>(context, listen: false)
              .addProduct(_product);
        } catch (error) {
          await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Error occured'),
              content: Text('Something went wrong'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text('Ok'))
              ],
            ),
          );
        } finally {
          Navigator.of(context).pop();
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty)
                            return null;
                          else
                            return 'This value is empty';
                        },
                        onSaved: (value) {
                          if (value != null)
                            _product = Product(
                                id: _product.id,
                                title: value,
                                description: _product.description,
                                price: _product.price,
                                imageUrl: _product.imageUrl,
                                isFavorite: _product.isFavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.tryParse(value)! <= 0) {
                              return 'Please enter a positive number';
                            }
                            return null;
                          } else
                            return 'This value is empty';
                        },
                        onSaved: (value) {
                          if (value != null)
                            _product = Product(
                                id: _product.id,
                                title: _product.title,
                                description: _product.description,
                                price: double.parse(value),
                                imageUrl: _product.imageUrl,
                                isFavorite: _product.isFavorite);
                        },
                      ),
                      TextFormField(
                          initialValue: _initValues['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value != null && value.isNotEmpty)
                              return null;
                            else
                              return 'Please enter a description';
                          },
                          onSaved: (value) {
                            if (value != null)
                              _product = Product(
                                  id: _product.id,
                                  title: _product.title,
                                  description: value,
                                  price: _product.price,
                                  imageUrl: _product.imageUrl,
                                  isFavorite: _product.isFavorite);
                          }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                              ),
                              child: _imageUrlController.text.isEmpty
                                  ? Text('Enter a Url')
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.fill,
                                      ),
                                    )),
                          Expanded(
                            child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlController,
                                focusNode: _imageUrlFocusNode,
                                onEditingComplete: () {
                                  setState(() {});
                                },
                                onFieldSubmitted: (_) {
                                  _saveForm();
                                },
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (!value.startsWith('http') &&
                                        !value.startsWith('https'))
                                      return 'Please return a valid image';

                                    return null;
                                  } else
                                    return 'This value is empty';
                                },
                                onSaved: (value) {
                                  if (value != null)
                                    _product = Product(
                                        id: _product.id,
                                        title: _product.title,
                                        description: _product.description,
                                        price: _product.price,
                                        imageUrl: value,
                                        isFavorite: _product.isFavorite);
                                }),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
