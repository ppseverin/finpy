import setuptools

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name='pynet',
    version='0.1.18',
    author='Pedro Severin',
    author_email='ppseverin@miuandes.cl',
    description='Python NNFX Indicator Library',
    long_description=long_description,
    long_description_content_type="text/markdown",
    url='https://github.com/ppseverin/finpy',
    license='MIT',
    packages=setuptools.find_packages(),
    install_requires=[
        'numpy==1.23.5',
        "pandas==1.5.3",
        "ta-lib==0.4.25"
    ]
)
