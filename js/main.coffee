camera   = undefined
scene    = undefined
renderer = undefined
mesh     = undefined
texture  = undefined
controls = undefined

glows    = []
glows_rv = [0..10].map ->(Math.random()-Math.random())/100.0

obj_loader =(mat)->
    manager = new THREE.LoadingManager()
    manager.onProgress = (i,l,p)->console.log i,l,p
    
    loader = new THREE.OBJLoader manager
    loader.load "img/drop.obj", (obj)->
        obj.scale.set 50.0, 50.0, 50.0
        obj.traverse (c)->
            console.log c
            if c instanceof THREE.Mesh then c.material = mat
        scene.add obj
        obj.material = mat
        mesh = obj
        
init = ->

    camera = new (THREE.PerspectiveCamera)(70, window.innerWidth / window.innerHeight, 1, 1000)
    camera.position.z = 400
    controls = new THREE.OrbitControls camera
    
    background = new THREE.Color 0xFA953C
    scene = new THREE.Scene
    scene.background = background

    tl = new THREE.TextureLoader
    cubeTexture = new THREE.CubeTextureLoader()
                    .setPath( 'img/' )
                    .load( [ 'posx.jpg', 'negx.jpg', 'posy.jpg', 'negy.jpg', 'posz.jpg', 'negz.jpg' ] );

    cubeTexture.mapping = THREE.CubeRefractionMapping
    cubeTexture.format  = THREE.RGBFormat

    # particles
    glowTex = tl.load("img/glow.png")
    glowMat = new THREE.SpriteMaterial
        map: glowTex
        color: 0x555555
        blending: THREE.AdditiveBlending
    glowSpr = new THREE.Sprite glowMat
    glowSpr.scale.set 200.0, 200.0, 1.0
    scene.add glowSpr

    for i in [0..10]    
        glowMat = new THREE.SpriteMaterial
            map: glowTex
            color: 0x202020
            blending: THREE.AdditiveBlending
            rotation: Math.random()*3.141*2.0
        glows.push glowMat
        glowSpr = new THREE.Sprite glowMat
        glowSpr.scale.set 200.0+Math.random()*100.0,10.0+Math.random()*20, 1.0
        scene.add glowSpr
        
    glowMat = new THREE.SpriteMaterial
        map: glowTex
        color: 0x202020
        blending: THREE.AdditiveBlending

    rr = ->Math.random()-Math.random()
    for i in [0..100]
        s = Math.random()*200.0+10.0
        glowSpr = new THREE.Sprite glowMat
        glowSpr.position.set rr(),rr(),rr()
        glowSpr.position.normalize()
        glowSpr.position.multiplyScalar 400.0+Math.rnadom()*200.0
        glowSpr.scale.set s, s, 1.0
        scene.add glowSpr

    # scene.background = cubeTexture

    # ambient = new THREE.AmbientLight 0xffffff
    # scene.add ambient
    
    pointLight = new THREE.PointLight 0xffffff, 2
    pointLight.position.set(500, 500, 1000)
    scene.add pointLight

    pointLight = new THREE.PointLight 0xFF9933, 2
    pointLight.position.set(-500, -500, 100)
    scene.add pointLight

    material = new THREE.MeshPhongMaterial
        color: 0xDA751C
        envMap: cubeTexture
        reflectivity: 0.5
        combine: THREE.MixOperation

    obj_loader material
    # geometry = new THREE.SphereBufferGeometry 200, 10
    # mesh = new THREE.Mesh geometry, material
    # scene.add mesh

    renderer = new THREE.WebGLRenderer antialias: true
    renderer.setPixelRatio window.devicePixelRatio
    renderer.setSize window.innerWidth, window.innerHeight
    document.body.appendChild renderer.domElement

    window.addEventListener 'resize', onWindowResize, false

onWindowResize = ->
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize window.innerWidth, window.innerHeight
    return

animate = ->
    requestAnimationFrame animate
    controls?.update()
    for g, i in glows
        g.rotation += glows_rv[i]

    # mesh?.rotation.x += 0.005
    # mesh?.rotation.y += 0.01
    renderer.render scene, camera
    return

init()
animate()
