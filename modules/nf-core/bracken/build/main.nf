process BRACKEN_BUILD {
    tag "$meta.id"
    label 'process_medium'
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bracken:2.9--py39h1f90b4d_0':
        'biocontainers/bracken:2.9--py39h1f90b4d_0' }"
    
    input:
    tuple val(meta), path(db)

    output:
    tuple val(meta), path("$prefix"), emit: db
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bracken-build \\
        -d ${db} \\
        -t $task.cpus \\
        $args
    if [[ \$(basename ${db}) != "${prefix}" ]]; then
        mv ${db}/* ${prefix}
    fi
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bracken: \$(echo \$(bracken -v) | cut -f2 -d'v')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p "$prefix"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bracken: \$(echo \$(bracken -v) | cut -f2 -d'v')
    END_VERSIONS
    """
}
