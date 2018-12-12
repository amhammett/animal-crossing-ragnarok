.PHONEY = help run build_love test

game_code := acr
build_dir := build
dist_dir := dist

help: ## this help text
	@echo 'Available targets'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# dev
run: ## run the game
	love .

# build
build_love: ## generate love file
	rm -rf $(build_dir) $(dist_dir)
	mkdir $(build_dir) $(dist_dir)
	cp *.lua $(build_dir)/
	cp README.md $(build_dir)/
	cp -r lib $(build_dir)/lib
	cp -r assets $(build_dir)/assets
	cd $(dist_dir) ; zip -r ../$(dist_dir)/$(game_code).zip ../$(build_dir)/* ; cd ..

# test
test: | lua_lint

lua_lint: ## lint lua files
	@echo lint
