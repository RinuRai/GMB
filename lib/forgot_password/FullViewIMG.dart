import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';



class FullPageImage extends StatelessWidget {
  final String imageUrl;

  FullPageImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child:
          PhotoViewGallery.builder(
            itemCount: 1, // Number of images in the gallery
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Colors.transparent,
            ),
            pageController: PageController(),
            onPageChanged: (index) {
              // Handle page change if needed
            },
          ),
          
          

        ),
      ),
    );
  }
}
