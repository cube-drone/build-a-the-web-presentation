default:
	mdbook serve --open

deploy:
	mdbook build
	echo "Public Upload Activating..."
	cp -r ./book/* /s/Public/tech_books/how-to-build/
	echo "Public Upload Complete!"