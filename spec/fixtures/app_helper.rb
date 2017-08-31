# frozen_string_literal: true

class AppHelper
  class << self
    def root
      File.expand_path(
        "./app",
        File.dirname(__FILE__)
      )
    end

    def tree # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      {
        name: "App",
        path: root,
        type: "Ruby & JS",
        ancestry: Set.new,
        dependencies: [
          {
            name: "a",
            path: "#{root}/components/a",
            type: "Ruby",
            ancestry: Set.new(
              [
                { name: "App", path: root, type: "Ruby & JS" },
              ]
            ),
            dependencies: [
              {
                name: "b",
                path: "#{root}/components/b",
                type: "Ruby & JS",
                ancestry: Set.new(
                  [
                    { name: "App", path: root, type: "Ruby & JS" },
                    { name: "a", path: "#{root}/components/a", type: "Ruby" },
                  ]
                ),
                dependencies: [
                  {
                    name: "g",
                    path: "#{root}/components/g",
                    type: "JS",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root, type: "Ruby & JS" },
                        { name: "a", path: "#{root}/components/a", type: "Ruby" },
                        { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "e",
                        path: "#{root}/components/e",
                        type: "JS",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root, type: "Ruby & JS" },
                            { name: "a", path: "#{root}/components/a", type: "Ruby" },
                            { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                            { name: "g", path: "#{root}/components/g", type: "JS" },
                          ]
                        ),
                        dependencies: [],
                      },
                      {
                        name: "f",
                        path: "#{root}/components/f",
                        type: "JS",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root, type: "Ruby & JS" },
                            { name: "a", path: "#{root}/components/a", type: "Ruby" },
                            { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                            { name: "g", path: "#{root}/components/g", type: "JS" },
                          ]
                        ),
                        dependencies: [],
                      },
                    ],
                  },
                ],
              },
              {
                name: "c",
                path: "#{root}/components/c",
                type: "Ruby",
                ancestry: Set.new(
                  [
                    { name: "App", path: root, type: "Ruby & JS" },
                    { name: "a", path: "#{root}/components/a", type: "Ruby" },
                  ]
                ),
                dependencies: [
                  {
                    name: "b",
                    path: "#{root}/components/b",
                    type: "Ruby & JS",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root, type: "Ruby & JS" },
                        { name: "a", path: "#{root}/components/a", type: "Ruby" },
                        { name: "c", path: "#{root}/components/c", type: "Ruby" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "g",
                        path: "#{root}/components/g",
                        type: "JS",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root, type: "Ruby & JS" },
                            { name: "a", path: "#{root}/components/a", type: "Ruby" },
                            { name: "c", path: "#{root}/components/c", type: "Ruby" },
                            { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                          ]
                        ),
                        dependencies: [
                          {
                            name: "e",
                            path: "#{root}/components/e",
                            type: "JS",
                            ancestry: Set.new(
                              [
                                { name: "App", path: root, type: "Ruby & JS" },
                                { name: "a", path: "#{root}/components/a", type: "Ruby" },
                                { name: "c", path: "#{root}/components/c", type: "Ruby" },
                                { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                                { name: "g", path: "#{root}/components/g", type: "JS" },
                              ]
                            ),
                            dependencies: [],
                          },
                          {
                            name: "f",
                            path: "#{root}/components/f",
                            type: "JS",
                            ancestry: Set.new(
                              [
                                { name: "App", path: root, type: "Ruby & JS" },
                                { name: "a", path: "#{root}/components/a", type: "Ruby" },
                                { name: "c", path: "#{root}/components/c", type: "Ruby" },
                                { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                                { name: "g", path: "#{root}/components/g", type: "JS" },
                              ]
                            ),
                            dependencies: [],
                          },
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },
          {
            name: "d",
            path: "#{root}/components/d",
            type: "Ruby",
            ancestry: Set.new(
              [
                { name: "App", path: root, type: "Ruby & JS" },
              ]
            ),
            dependencies: [
              {
                name: "b",
                path: "#{root}/components/b",
                type: "Ruby & JS",
                ancestry: Set.new(
                  [
                    { name: "App", path: root, type: "Ruby & JS" },
                    { name: "d", path: "#{root}/components/d", type: "Ruby" },
                  ]
                ),
                dependencies: [
                  {
                    name: "g",
                    path: "#{root}/components/g",
                    type: "JS",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root, type: "Ruby & JS" },
                        { name: "d", path: "#{root}/components/d", type: "Ruby" },
                        { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "e",
                        path: "#{root}/components/e",
                        type: "JS",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root, type: "Ruby & JS" },
                            { name: "d", path: "#{root}/components/d", type: "Ruby" },
                            { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                            { name: "g", path: "#{root}/components/g", type: "JS" },
                          ]
                        ),
                        dependencies: [],
                      },
                      {
                        name: "f",
                        path: "#{root}/components/f",
                        type: "JS",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root, type: "Ruby & JS" },
                            { name: "d", path: "#{root}/components/d", type: "Ruby" },
                            { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                            { name: "g", path: "#{root}/components/g", type: "JS" },
                          ]
                        ),
                        dependencies: [],
                      },
                    ],
                  },
                ],
              },
              {
                name: "c",
                path: "#{root}/components/c",
                type: "Ruby",
                ancestry: Set.new(
                  [
                    { name: "App", path: root, type: "Ruby & JS" },
                    { name: "d", path: "#{root}/components/d", type: "Ruby" },
                  ]
                ),
                dependencies: [
                  {
                    name: "b",
                    path: "#{root}/components/b",
                    type: "Ruby & JS",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root, type: "Ruby & JS" },
                        { name: "d", path: "#{root}/components/d", type: "Ruby" },
                        { name: "c", path: "#{root}/components/c", type: "Ruby" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "g",
                        path: "#{root}/components/g",
                        type: "JS",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root, type: "Ruby & JS" },
                            { name: "d", path: "#{root}/components/d", type: "Ruby" },
                            { name: "c", path: "#{root}/components/c", type: "Ruby" },
                            { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                          ]
                        ),
                        dependencies: [
                          {
                            name: "e",
                            path: "#{root}/components/e",
                            type: "JS",
                            ancestry: Set.new(
                              [
                                { name: "App", path: root, type: "Ruby & JS" },
                                { name: "d", path: "#{root}/components/d", type: "Ruby" },
                                { name: "c", path: "#{root}/components/c", type: "Ruby" },
                                { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                                { name: "g", path: "#{root}/components/g", type: "JS" },
                              ]
                            ),
                            dependencies: [],
                          },
                          {
                            name: "f",
                            path: "#{root}/components/f",
                            type: "JS",
                            ancestry: Set.new(
                              [
                                { name: "App", path: root, type: "Ruby & JS" },
                                { name: "d", path: "#{root}/components/d", type: "Ruby" },
                                { name: "c", path: "#{root}/components/c", type: "Ruby" },
                                { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                                { name: "g", path: "#{root}/components/g", type: "JS" },
                              ]
                            ),
                            dependencies: [],
                          },
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },
          {
            name: "node_manifest",
            path: "#{root}/node_manifest",
            type: "JS",
            ancestry: Set.new(
              [
                { name: "App", path: root, type: "Ruby & JS" },
              ]
            ),
            dependencies: [
              {
                name: "b",
                path: "#{root}/components/b",
                type: "Ruby & JS",
                ancestry: Set.new(
                  [
                    { name: "App", path: root, type: "Ruby & JS" },
                    { name: "node_manifest", path: "#{root}/node_manifest", type: "JS" },
                  ]
                ),
                dependencies: [
                  {
                    name: "g",
                    path: "#{root}/components/g",
                    type: "JS",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root, type: "Ruby & JS" },
                        { name: "node_manifest", path: "#{root}/node_manifest", type: "JS" },
                        { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "e",
                        path: "#{root}/components/e",
                        type: "JS",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root, type: "Ruby & JS" },
                            { name: "node_manifest", path: "#{root}/node_manifest", type: "JS" },
                            { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                            { name: "g", path: "#{root}/components/g", type: "JS" },
                          ]
                        ),
                        dependencies: [],
                      },
                      {
                        name: "f",
                        path: "#{root}/components/f",
                        type: "JS",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root, type: "Ruby & JS" },
                            { name: "node_manifest", path: "#{root}/node_manifest", type: "JS" },
                            { name: "b", path: "#{root}/components/b", type: "Ruby & JS" },
                            { name: "g", path: "#{root}/components/g", type: "JS" },
                          ]
                        ),
                        dependencies: [],
                      },
                    ],
                  },
                ],
              },
              {
                name: "e",
                path: "#{root}/components/e",
                type: "JS",
                ancestry: Set.new(
                  [
                    { name: "App", path: root, type: "Ruby & JS" },
                    { name: "node_manifest", path: "#{root}/node_manifest", type: "JS" },
                  ]
                ),
                dependencies: [],
              },
              {
                name: "f",
                path: "#{root}/components/f",
                type: "JS",
                ancestry: Set.new(
                  [
                    { name: "App", path: root, type: "Ruby & JS" },
                    { name: "node_manifest", path: "#{root}/node_manifest", type: "JS" },
                  ]
                ),
                dependencies: [],
              },
              {
                name: "g",
                path: "#{root}/components/g",
                type: "JS",
                ancestry: Set.new(
                  [
                    { name: "App", path: root, type: "Ruby & JS" },
                    { name: "node_manifest", path: "#{root}/node_manifest", type: "JS" },
                  ]
                ),
                dependencies: [
                  {
                    name: "e",
                    path: "#{root}/components/e",
                    type: "JS",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root, type: "Ruby & JS" },
                        { name: "node_manifest", path: "#{root}/node_manifest", type: "JS" },
                        { name: "g", path: "#{root}/components/g", type: "JS" },
                      ]
                    ),
                    dependencies: [],
                  },
                  {
                    name: "f",
                    path: "#{root}/components/f",
                    type: "JS",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root, type: "Ruby & JS" },
                        { name: "node_manifest", path: "#{root}/node_manifest", type: "JS" },
                        { name: "g", path: "#{root}/components/g", type: "JS" },
                      ]
                    ),
                    dependencies: [],
                  },
                ],
              },
            ],
          },
        ],
      }
    end
  end
end
