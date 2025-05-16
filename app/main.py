from app.module import module


def get_str(arg: str):
	return f"get a string {arg}"


def main() -> None:
	module()
	print("Hello, World!")
	print(get_str("alovc"))

if __name__ == "__main__":
	main()
