from setuptools import setup

setup(
    name="venus",
    setup_requires=['setuptools_scm'],
    packages=["venus"],
    use_scm_version = True,
    include_package_data=True,
    package_data={"venus": [
        "venus/data/config.schema.yaml",
        "venus/snakemake/*.smk",
        "venus/snakemake/envs/*.yaml"
    ]},
    entry_points={'console_scripts': [
        'venus = venus.command:main',
    ]},
    install_requires=[
        'snakemake>5.1,<6',
        'coloredlogs',
        'seamlessf5',
        'pandas'
    ]
)
