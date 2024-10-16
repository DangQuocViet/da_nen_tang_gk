// ignore_for_file: prefer_const_constructors, avoid_print, unused_local_variable, no_leading_underscores_for_local_identifiers, unnecessary_brace_in_string_interps, curly_braces_in_flow_control_structures, prefer_final_fields, unused_import

import 'dart:io';

import 'package:app_gk/Login%20SignUp/Services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'Login SignUp/Screen/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _loaiController = TextEditingController();
  final TextEditingController _giaController = TextEditingController();

  CollectionReference _users =
      FirebaseFirestore.instance.collection("products");
  String imageUrl = '';
  /////add
  _addProduct() async {
    print("image url when save " + imageUrl);
    await _users.add({
      'name': _nameController.text,
      'loai': _loaiController.text,
      'gia': _giaController.text,
      'imageUrl': imageUrl, // Lưu URL hình ảnh
    });

    _nameController.clear();
    _loaiController.clear();
    _giaController.clear();
  }

  ////delete
  void _deleteUser(String userId) {
    _users.doc(userId).delete();
  }

  ///edit
  void _editUser(DocumentSnapshot user) {
    _nameController.text = user['name'];
    _loaiController.text = user['loai'];
    _giaController.text = user['gia'];

    /////form sua
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit product"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Product name",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black87, // Set the color of the outline to black when focused
                        width:
                            2.0, // You can adjust the width of the border as desired
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _loaiController,
                  decoration: InputDecoration(
                    labelText: "Product Type",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black87, // Set the color of the outline to black when focused
                        width:
                            2.0, // You can adjust the width of the border as desired
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _giaController,
                  decoration: InputDecoration(
                    labelText: "Product Price",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors
                            .black87, // Set the color of the outline to black when focused
                        width:
                            2.0, // You can adjust the width of the border as desired
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.grey, // Set the background color to black
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Set the border radius to 8
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors
                          .white, // Set the text color to white (or any color you prefer)
                    ),
                  )),
              ElevatedButton(
                  onPressed: () {
                    _updateUser(user.id);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.black, // Set the background color to black
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Set the border radius to 8
                    ),
                  ),
                  child: Text("Save")),
            ],
          );
        });
  }

  ///update
  void _updateUser(String userId) {
    _users.doc(userId).update({
      'name': _nameController.text,
      'loai': _loaiController.text,
      'gia': _giaController.text,
    });
    _nameController.clear();
    _loaiController.clear();
    _giaController.clear();
  }

  // up ảnh
  String? selectedFileName;
  Uint8List? selectedFileBytes; // Thay đổi kiểu từ List<int> thành Uint8List

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image, // Chỉ cho phép chọn tệp hình ảnh
      );

      if (result != null) {
        setState(() {
          selectedFileName = result.files.single.name; // Lấy tên tệp
          selectedFileBytes = result.files.single.bytes; // Lấy bytes
        });
        print('File name: $selectedFileName');
        print('Byte of file: ${selectedFileBytes?.length}');
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('Error when select file: $e');
    }
  }

  Future<void> uploadFileToStorage() async {
    if (selectedFileBytes == null) {
      print('No file selected to upload.');
      return;
    }
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Tham chiếu đến thư mục images
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      // Tải tệp lên Firebase Storage bằng cách sử dụng dữ liệu byte và kiểu MIME
      await referenceImageToUpload.putData(
        selectedFileBytes!,
        SettableMetadata(contentType: 'image/jpeg'), // Hoặc 'image/png'
      );

      // Lấy URL của tệp đã tải lên
      imageUrl = await referenceImageToUpload.getDownloadURL();
      print('Upload image successfully, URL: $imageUrl');

      /// lưu
    } catch (error) {
      print('Error when upload file: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Product management",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.white,
            onPressed: () async {
              await AuthMethod().googleSignOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              ); // Gọi phương thức đăng xuất
              // Điều hướng đến màn hình đăng nhập nếu cần
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Enter the product name",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors
                        .black87, // Set the color of the outline to black when focused
                    width:
                        2.0, // You can adjust the width of the border as desired
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: _loaiController,
              decoration: InputDecoration(
                labelText: "Enter the product type",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors
                        .black87, // Set the color of the outline to black when focused
                    width:
                        2.0, // You can adjust the width of the border as desired
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: _giaController,
              decoration: InputDecoration(
                labelText: "Enter the product price",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors
                        .black87, // Set the color of the outline to black when focused
                    width:
                        2.0, // You can adjust the width of the border as desired
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                await pickFile(); // Add your file picker logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.black87, // Set background color of button
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Optional: for rounded corners
                ),
              ),
              child: Image.network(
                'assets/upload.png', // URL of your custom image
                width: 150, // Set width of the image
                height: 150, // Set height of the image
              ),
            ),
            if (selectedFileName != null) ...[
              SizedBox(height: 20),
              Text('Selected file: $selectedFileName'),
            ],
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                await uploadFileToStorage();
                await _addProduct();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.black, // Set the background color to black
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Set the border radius to 8
                ),
              ),
              child: Text(
                "Create",
                style: TextStyle(
                  color: Colors.white, // Set text color to white for contrast
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Expanded(
                child: StreamBuilder(
              stream: _users.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var user = snapshot.data!.docs[index];

                    return Dismissible(
                      key: Key(user.id),
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteUser(user.id);
                      },
                      direction: DismissDirection.endToStart,
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8.0),
                          // Sử dụng Row để hiển thị ảnh và thông tin sản phẩm theo hàng ngang
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hiển thị hình ảnh từ URL
                              user['imageUrl'] != null &&
                                      user['imageUrl'].isNotEmpty
                                  ? Image.network(
                                      user['imageUrl'],
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported),
                                    ),
                              SizedBox(width: 16),
                              SizedBox(
                                  width:
                                      16), // Khoảng cách giữa ảnh và thông tin

                              // Hiển thị thông tin sản phẩm
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Product name: ',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: user['name'],
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Product price: ',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: user['gia'],
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Product type: ',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: user['loai'],
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _editUser(user);
                                },
                                icon: Icon(Icons.edit),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
